require "bundler/setup"
require "boolean_timestamp"
require "timecop"
require_relative "support/test_database"

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

  adapter = ENV["DB_ADAPTER"] || "sqlite"
  test_database = TestDatabase.new(adapter)

  config.before(:suite) do
    puts "Running #{adapter} tests"
    test_database.setup
  end

  config.after(:suite) do
    test_database.teardown
  end
end
