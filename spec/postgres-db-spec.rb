require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/postgres-manage.yml", {
      new_db_user: "db_owner",
      new_db_pass: "password",
      db_name: "test_db"
    })
  end
end

describe "Database should be created" do
  before(:each) do
    set :env, :PGPASSWORD => 'vagrant'
  end

  describe command(%Q{psql -w -U vagrant postgres -c "SELECT count(*) FROM pg_database WHERE datname = 'test_db'"}) do
    it "should include test_db as a database" do
      expect(subject.stdout).to match /^\s*1\s*$/
    end
  end

  describe command(%Q{psql -w -U vagrant postgres -c "SELECT u.usename FROM pg_database d JOIN pg_user u ON d.datdba = u.usesysid WHERE d.datname = 'test_db'"}) do
    it "should have db_owner as the database owner" do
      expect(subject.stdout).to match /^\s*db_owner\s*$/
    end
  end

  describe command(%Q{psql -w -U vagrant postgres -c "SELECT rolsuper, rolcreaterole, rolcreatedb, rolcatupdate, rolcanlogin, rolreplication FROM pg_roles WHERE rolname = 'db_owner'"}) do
    it "should not grant db_owner any global privileges" do
      expect(subject.stdout).to match /^\s*f\s*\|\s*f\s*\|\s*f\s*\|\s*f\s*\|\s*t\s*\|\s*f\s*$/
    end
  end
end

describe "DB owner should be able to connect to the database" do
  before(:each) do
    set :env, :PGPASSWORD => 'password'
  end

  describe command(%Q{psql -w -U db_owner test_db -c "SELECT 'hello'"}) do
    its(:stdout) { should match /hello/ }

    its(:exit_status) { should eq 0 }
  end
end
