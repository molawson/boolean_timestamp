require "bundler/setup"
require "boolean_timestamp"
require "timecop"
require "active_record/tasks/database_tasks"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

def create_database_schema(config)
  ActiveRecord::Base.establish_connection(config)
  ActiveRecord::Schema.define do
    suppress_messages do
      create_table :articles do |t|
        t.string :title
        t.timestamp :published_at
      end
    end
  end
end

def create_mysql_database(config)
  ActiveRecord::Tasks::MySQLDatabaseTasks.new(config).create
rescue ActiveRecord::Tasks::DatabaseAlreadyExists
  ActiveRecord::Tasks::MySQLDatabaseTasks.new(config).drop
  ActiveRecord::Tasks::MySQLDatabaseTasks.new(config).create
end

def setup_database(config)
  create_mysql_database(config) if config["adapter"] == "mysql2"
  create_database_schema(config)
end

def teardown_database(config)
  return unless config["adapter"] == "mysql2"

  ActiveRecord::Tasks::MySQLDatabaseTasks.new(config).drop
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  DB_CONFIG = {
    "sqlite" => {
      adapter: "sqlite3",
      database: ":memory:",
    },
    "mysql" => {
      "adapter" => "mysql2",
      "host" => "127.0.0.1",
      "username" => "root",
      "password" => nil,
      "database" => "boolean_timestamp_test",
    },
  }.freeze
  adapter = ENV["DB_ADAPTER"] || "sqlite"
  adapter_config = DB_CONFIG.fetch(adapter)

  config.before(:suite) do
    puts "Running #{adapter} tests"
    setup_database(adapter_config)
  end

  config.after(:suite) do
    teardown_database(adapter_config)
  end
end
