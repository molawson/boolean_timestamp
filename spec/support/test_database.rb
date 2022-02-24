require "active_record/tasks/database_tasks"

DB_CONFIG = {
  "sqlite" => {
    adapter: "sqlite3",
    database: ":memory:"
  },
  "mysql" => {
    "adapter" => "mysql2",
    "host" => "127.0.0.1",
    "username" => "root",
    "password" => "root",
    "database" => "boolean_timestamp_test",
    "collation" => "utf8mb4_general_ci"
  },
  "postgres" => {
    "adapter" => "postgresql",
    "encoding" => "unicode",
    "database" => "boolean_timestamp_test",
    "username" => "postgres"
  }
}.freeze

DB_ALREADY_EXISTS_ERROR = if ActiveRecord.const_defined?("DatabaseAlreadyExists")
  ActiveRecord::DatabaseAlreadyExists
else
  ActiveRecord::Tasks::DatabaseAlreadyExists
end

class TestDatabase
  def initialize(adapter)
    @adapter = adapter.to_s
  end

  def setup
    create
    load_schema
  end

  def teardown
    tasks&.drop
  end

  private

  attr_reader :adapter

  def config
    @config ||= begin
      config_hash = DB_CONFIG.fetch(adapter)
      if ActiveRecord.version >= Gem::Version.new("6.1.0")
        ActiveRecord::DatabaseConfigurations::HashConfig.new("default_env", "primary", config_hash)
      else
        config_hash
      end
    end
  end

  def tasks
    @tasks ||= case adapter
               when "mysql"
                 ActiveRecord::Tasks::MySQLDatabaseTasks.new(config)
               when "postgres"
                 ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(config)
    end
  end

  def load_schema
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

  def create
    return unless tasks

    tasks.create
  rescue DB_ALREADY_EXISTS_ERROR
    tasks.drop
    tasks.create
  end
end
