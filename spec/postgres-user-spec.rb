require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/postgres-manage.yml", {
      new_postgres_user: "test_user",
      new_postgres_pass: "password"
    })
  end
end

describe "New user should be created" do
  before(:each) do
    set :env, :PGPASSWORD => 'password'
  end

  describe command("psql -w -U test_user postgres -c \"SELECT count(*) FROM pg_shadow WHERE usename = 'test_user'\"") do
    its(:stdout) { should match /^\s*1\s*$/ }

    its(:exit_status) { should eq 0 }
  end

  describe command("psql -w -U test_user postgres -c \"SELECT passwd FROM pg_shadow WHERE usename = 'test_user'\"") do
    its(:stdout) { should match /s*md5/ }

    its(:exit_status) { should eq 0 }
  end
end
