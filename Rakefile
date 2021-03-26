require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

namespace :spec do
  desc "Run tests with sqlite3 adapter"
  task :sqlite do
    ENV["DB_ADAPTER"] = "sqlite"
    Rake::Task["spec"].execute
  end

  desc "Run tests with mysql2 adapter"
  task :mysql do
    ENV["DB_ADAPTER"] = "mysql"
    Rake::Task["spec"].execute
  end

  desc "Run tests with postgresql adapter"
  task :postgres do
    ENV["DB_ADAPTER"] = "postgres"
    Rake::Task["spec"].execute
  end

  desc "Run tests with all adapters"
  task :all do
    Rake::Task["spec:sqlite"].execute
    Rake::Task["spec:mysql"].execute
    Rake::Task["spec:postgres"].execute
  end
end

task default: %i[spec standard]
