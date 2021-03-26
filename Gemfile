source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in boolean_timestamp.gemspec
gemspec

gem "appraisal"
gem "mysql2"
gem "pg"
gem "rake", ">= 12.3.3"
gem "rspec", "~> 3.0"
gem "rubocop", "0.54.0"
gem "sqlite3"
gem "timecop"

group :test do
  gem "simplecov", require: false
end
