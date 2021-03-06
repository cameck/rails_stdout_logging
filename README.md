# Rails Stdout JSON Logging

Rails gem to configure your app to log to standard out.  
This is a fork of https://github.com/heroku/rails_stdout_logging and the only difference currently is that it formats logs in JSON.  
This may or may not fit your use case.


Supports:

- Rails 3
- Rails 4



## Install

In your `Gemfile` add:

```
gem 'rails_stdout_json_logging'
```

Then run

```
$ bundle install
```

You also need the [`rails_serve_static_assets` gem](https://github.com/heroku/rails_serve_static_assets).
You can get both of them together by installing the [`rails_12factor` gem](https://github.com/heroku/rails_12factor).

## Why is this needed?

By default Rails writes its logs to a file, which is convenient because you only have one log file to tail. When you start scaling your app to multiple machines or dynos, it becomes much harder to find a single request or failure as they're spread across multiple files. Storing logs on disk can also take down a server if the hard drive fills up. Because of these limitations, every Rails core member we talked to uses a custom logger to replace Rails' default functionality. By using the `rails_stdout_json_logging` gem with Heroku, we set the logger for you.

The gem `rails_stdout_json_logging` ensures that your logs will be sent to standard out. From there, Heroku sends them to [logplex](https://github.com/heroku/logplex) so you can access them from the command line like `$ heroku logs --tail`, or from enabled addons like [papertrail](https://addons.heroku.com/papertrail). By using Heroku's logplex, you can [treat logs as event streams](http://www.12factor.net/logs).

## Why didn't I need this before?

Why do you need to include this gem in Rails 4 and not Rails 3? Rails4 is getting rid of the concept of plugins. Before libraries were easily distributed as Gems and in the form of Engines, Rails had a folder `vendor/plugins`. Any code you put there would be initialized much like a Gem is today. This was a very simple and easy way to share and use libraries, but it wasn't very maintainable. You could use a library, and make a change locally and then deploy which makes your version incompatible from future versions. Even worse there was no concept of versioning aside from source control, so semantic versioning was out of the question. For these reasons and more Rails3 deprecated plugins. With Rails4 plugins have been removed completely. Why does this affect your app on Heroku?

In the past Heroku has used plugins as a safe way to configure your application where code was needed. While we advocate [separating config from code](http://12factor.net), this was the only option if we wanted your apps to work with no changes from you. With Rails3 Heroku will add the asset serving and standardout logging plugins to your app automatically. With Rails4, Heroku needs you to add these libraries to your Gemfile.

It is important to note that unlike Gems, plugins do not have a dependency resolution phase like what happens when you run `bundle install`. Heroku does not and will not add anything to your Gemfile on compilation.


## Set log level

On Heroku you can set your log level by using the `LOG_LEVEL` environment variable

```sh
$ heroku config:set LOG_LEVEL=DEBUG
```

Valid values include `DEBUG`, `INFO`, `WARN`, `ERROR`, and `FATAL`. Alternatively you can set this value in your environment config:

```
config.log_level = :debug
```

If both are set `LOG_LEVEL` will take precedence.

## Tests

Since we're playing with stdout we need to capture stdout. If you want to use the non captured version use `DEBUG_STDOUT` instead. The `puts` method should still behave as you expect.

We're using appraisal to build multiple gemfiles for different versions of Rails.

You can run all tests by running

```
$ bundle exec rake appraisal test
```


## Rails 5

We worked with the Rails core team to make Rails 5 work on twelve-factor platforms out of the box.

### New Rails 5 Apps

If you are starting a new application with Rails 5, **you do not need this gem.**

### Migrating to Rails 5

You can remove this gem after making sure the following sections are added in
your `production.rb` file:

**`config/environments/production.rb`**
```ruby
# Disable serving static files from the `/public` folder by default since
# Apache or NGINX already handles this.
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

if ENV["RAILS_LOG_TO_STDOUT"].present?
  STDOUT.sync = true
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)
end
```

Make sure to add both the `RAILS_SERVE_STATIC_FILES` and `RAILS_LOG_TO_STDOUT` ENV vars and set them to `true`. (This is done for you on Heroku)
