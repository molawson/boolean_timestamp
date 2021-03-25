require "bundler/setup"
require "boolean_timestamp"
require "timecop"
require "active_record/tasks/database_tasks"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

DB_ALREADY_EXISTS_ERROR = if ActiveRecord.const_defined?("DatabaseAlreadyExists")
                            ActiveRecord::DatabaseAlreadyExists
                          else
                            ActiveRecord::Tasks::DatabaseAlreadyExists
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
  ActiveRecord::Tasks::MySQLDatabaseTasks.new(db_config config).create
rescue DB_ALREADY_EXISTS_ERROR
  ActiveRecord::Tasks::MySQLDatabaseTasks.new(db_config config).drop
  ActiveRecord::Tasks::MySQLDatabaseTasks.new(db_config config).create
end

def create_postgres_database(config)
  ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(db_config config).create
rescue DB_ALREADY_EXISTS_ERROR
  ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(db_config config).drop
  ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(db_config config).create
end

def setup_database(config)
  case config["adapter"]
  when "mysql2"
    create_mysql_database(config)
  when "postgresql"
    create_postgres_database(config)
  end
  create_database_schema(config)
end

def teardown_database(config)
  case config["adapter"]
  when "mysql2"
    ActiveRecord::Tasks::MySQLDatabaseTasks.new(db_config config).drop
  when "postgresql"
    ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(db_config config).drop
  end
end

def db_config(config_hash)
  if ActiveRecord.version >= Gem::Version.new("6.1.0")
    ActiveRecord::DatabaseConfigurations::HashConfig.new("default_env", "primary", config_hash)
  else
    config_hash
  end
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
      "collation" => "utf8mb4_general_ci",
    },
    "postgres" => {
      "adapter" => "postgresql",
      "encoding" => "unicode",
      "database" => "boolean_timestamp_test",
    },
  }.freeze
  adapter = ENV["DB_ADAPTER"] || "sqlite"
  config_hash = DB_CONFIG.fetch(adapter)

  config.before(:suite) do
    puts "Running #{adapter} tests"
    setup_database(config_hash)
  end

  config.after(:suite) do
    teardown_database(config_hash)
  end
end
