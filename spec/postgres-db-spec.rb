require_relative 'spec_helper'

RSpec.configure do |config|
  config.before :suite do
    SpecHelper.instance.provision('playbooks/postgres-manage.yml', {
      new_postgres_user: "db_owner",
      new_postgres_pass: "password",
      db_name: "test_db"
    })
  end
end

describe "Database should be created" do
  before(:each) do
    set :env, :PGPASSWORD => 'vagrant'
  end

  # datbase should be in pg_database
  describe command("psql -w -U vagrant postgres -c \"SELECT count(*) FROM pg_database WHERE datname = 'test_db'\"") do
    its(:stdout) { should match /^\s*1\s*$/ }
  end

  # db_owner should be the owner
  describe command("psql -w -U vagrant postgres -c \"SELECT u.usename FROM pg_database d JOIN pg_user u ON d.datdba = u.usesysid WHERE d.datname = 'test_db'\"") do
    its(:stdout) { should match /^\s*db_owner\s*$/ }
  end

  # db_owner should not have other privileges
  describe command("psql -w -U vagrant postgres -c \"SELECT rolsuper, rolcreaterole, rolcreatedb, rolcatupdate, rolcanlogin, rolreplication FROM pg_roles WHERE rolname = 'db_owner'\"") do
    its(:stdout) { should match /^\s*f\s*\|\s*f\s*\|\s*f\s*\|\s*f\s*\|\s*t\s*\|\s*f\s*$/ }
  end
end

describe "DB owner should be able to connect to the database" do
  before(:each) do
    set :env, :PGPASSWORD => 'password'
  end

  describe command("psql -w -U db_owner test_db -c \"SELECT 'hello'\"") do
    its(:stdout) { should match /hello/ }

    its(:exit_status) { should eq 0 }
  end
end
