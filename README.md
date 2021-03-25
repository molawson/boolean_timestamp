# BooleanTimestamp

[![Build Status](https://travis-ci.org/molawson/boolean_timestamp.svg?branch=main)](https://travis-ci.org/molawson/boolean_timestamp)
[![Maintainability](https://api.codeclimate.com/v1/badges/23eb9fb7a853d24551fa/maintainability)](https://codeclimate.com/github/molawson/boolean_timestamp/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/23eb9fb7a853d24551fa/test_coverage)](https://codeclimate.com/github/molawson/boolean_timestamp/test_coverage)

True/False fields have a great simplicity about them, and many times they're perfect for the job!
But, it's not uncommon end up in a place where you'd really love to keep some degree of simplicity with a little more detail about when the value was changed.
Sometimes you'll want to display that information to the user and other times you'll keep it for auditing or debugging purposes.
Either way, `boolean_timestamp` makes the job easy from the beginning and adds very little code to your app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "boolean_timestamp"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boolean_timestamp

## Usage

In any `ActiveRecord` model, you can define a boolean field based on a timestamp column by including the `BooleanTimestmap` module and calling a single method.

```ruby
class Article < ActiveRecord::Base
  include BooleanTimestamp
  boolean_timestamp :published # works with an existing column named `published_at`
end
```

The gem doesn't provide any code for setting up the database column. You'll need to use Rails migrations (or any other means you choose) to create the tables and columns you need.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/molawson/boolean_timestamp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BooleanTimestamp project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/molawson/boolean_timestamp/blob/main/CODE_OF_CONDUCT.md).
