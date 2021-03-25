
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "boolean_timestamp/version"

Gem::Specification.new do |spec|
  spec.name          = "boolean_timestamp"
  spec.version       = BooleanTimestamp::VERSION
  spec.authors       = ["Mo Lawson"]
  spec.email         = ["moklawson@gmail.com"]

  spec.summary       = %q{The precision of a timestamp column with the API of a boolean column}
  spec.description   = %q{True/False fields have a great simplicity about them, and many times
  they're perfect for the job! But, it's not uncommon end up in a place where you'd really love to
  keep some degree of simplicity with a little more detail about when the value was changed.
  Sometimes you'll want to display that information to the user and other times you'll keep it for
  auditing or debugging purposes. Either way, boolean_timestamp makes the job easy from the
  beginning and adds very little code to your app.}
  spec.homepage      = "https://github.com/molawson/boolean_timestamp"
  spec.license       = "MIT"
  spec.metadata      = {
    "homepage_uri" => "https://github.com/molawson/boolean_timestamp",
    "changelog_uri" => "https://github.com/molawson/boolean_timestamp/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/molawson/boolean_timestamp",
    "bug_tracker_uri" => "https://github.com/molawson/boolean_timestamp/issues",
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "0.54.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "timecop"

  spec.add_dependency "activerecord", "> 4.0"
end
