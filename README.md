# BooleanTimestamp

[![Build Status](https://app.travis-ci.com/molawson/boolean_timestamp.svg?branch=main)](https://app.travis-ci.com/molawson/boolean_timestamp)
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

Or install it yourself with:

    $ gem install boolean_timestamp

## Usage

### Model Setup
In any `ActiveRecord` model, you can define a boolean field based on a timestamp column by including the `BooleanTimestmap` module and calling a single method.

```ruby
class Article < ActiveRecord::Base
  include BooleanTimestamp
  boolean_timestamp :published
end
```

### Database Requirements
The only requirement is that you have a time-based column with a matching name, including the standard `_at` suffix.  In the example above, you'd need an `articles.published_at` column. 

The gem does not provide any code for setting up the database column. You'll need to use Rails migrations (or any other means you choose) to create the tables and columns you need.

### Convenience Methods
With this model setup, you get a number of methods for reading, writing, and querying a timestamp column as if it were a boolean, without restricting or altering any of the attributes that Rails adds for accessing the column directly.

```ruby
article = Article.new
article.published? # => false

article.published = true
article.published? # => true
article.published_at # => 2021-03-25 10:00:00 -0500

Article.new(published_at: Time.now).published? # => true

published = Article.create(title: "Published", published: true)
draft = Article.create(title: "Draft")
future = Article.create(title: "Future", published_at: Time.now + 86400)
Article.published # => [published]
Article.not_published # => [draft, future]
```

### (Not-so-)Strict Mode

By default, `boolean_timestamp` is strict about which `Time` values are considered `true` or `false`. A value in the future is considered false because if an article has a `published_at` value of "tomorrow at noon", then strictly speaking it hasn't been published yet. 

This is most useful in circumstances where you really care about that time value. For example, being strict about this lets you add features like auto-publishing articles at a future date. A user can finish writing the article and set a future `published_at` value when they want the article to be "released", and any query that fetches published articles will automatically start including it after we reach the `published_at` time.

In other cases, it's useful to have the timestamp value for debugging and reporting, but for all other intents and purposes, your code treats this data as boolean column. For example, you could have a `payments.failed_at` column. The timestamp is there mostly for historical reasons, the primary functio of that column is about separating the failed payments from those that didn't fail. You're not using this "a future value is falsey" feature of the library, but every time you lookup failed payments with `Payment.failed`, the query is going to use the current time, which can be needlessly slow (for this use-case) and is more difficult to cache (either explicitly in application code or by the database engine itself).

You can disable the current time checks for both querying and reading values on a per-attribute basis by passing the `strict: false` option. This will only treat `nil` values as `false`. Everything else is `true`. This does not change how values are written to the database.

```ruby
class Article < ActiveRecord::Base
  include BooleanTimestamp
  boolean_timestamp :published, strict: false
end

published = Article.create(title: "Published", published: true)
draft = Article.create(title: "Draft")
future = Article.create(title: "Future", published: Time.now + 86400)

# Where things start to behave differently

future.published? # => true
Article.published # => [published, future]
Article.not_published # => [draft]
```
## Version Support

This gem works with a variety of Ruby and Rails versions. The aim is to cover as broad a range of versions as is practical. This matrix should mostly reflect the versions of Ruby and Rails that are supported in some way by their maintainers (i.e. receiving at least some security patches).

| | Ruby 2.5 | Ruby 2.6 | Ruby 2.7 | Ruby 3.0 |
| --- | :---: | :---: | :---: | :---: |
| **Rails 5.2** | :white_check_mark: | :white_check_mark: | :white_check_mark: | :no_entry: |
| **Rails 6.0** | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| **Rails 6.1** | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| **Rails 7.0** | :no_entry: | :no_entry: | :white_check_mark: | :white_check_mark: |

* :white_check_mark: - fully tested and supported
* :no_entry: - not tested or supported
* :eight_pointed_black_star: - support and testing will be removed in the next major release of this gem (usually because at least one of the versions of Ruby or Rails has reached EOL for its maintainers)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can run the tests with `bundle exec rake`. That will run the tests against the latest version of Rails (from Gemfile.lock) and the SQLite database, so you'll need to have SQLite setup locally. You can also run the tests selectively against another database with `bundle exec rake spec:mysql` or `bundle exec rake spec:postgres`.  Or run all three database engine tests with `bundle exec rake spec:all`.

If you're feeling even more ambitious, this project uses [appraisal](https://github.com/thoughtbot/appraisal) to test against multiple versions of `ActiveRecord`. You can get all of those tests setup with `bundle exec appraisal install` and run them all with `bundle exec appraisal rake spec:all` (see the appraisal docs for more usage info, including running a single appraisal).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/molawson/boolean_timestamp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

1. Fork it ( https://github.com/molawson/repeatable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BooleanTimestamp project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/molawson/boolean_timestamp/blob/main/CODE_OF_CONDUCT.md).
