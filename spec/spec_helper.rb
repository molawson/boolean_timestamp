require "bundler/setup"
require "boolean_timestamp"
require "timecop"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: ":memory:",
  )

  ActiveRecord::Schema.define do
    suppress_messages do
      create_table :articles do |t|
        t.string :title
        t.timestamp :published_at
      end
    end
  end
end
