# Kronos
[![Build Status](https://semaphoreci.com/api/v1/pdvend/kronos/branches/master/badge.svg)](https://semaphoreci.com/pdvend/kronos)
[![Coverage Status](https://coveralls.io/repos/github/pdvend/kronos/badge.svg?branch=master)](https://coveralls.io/github/pdvend/kronos?branch=master)
[![Gem Version](https://badge.fury.io/rb/kronos-ruby.svg)](https://badge.fury.io/rb/kronos-ruby)
[![Dependency Status](https://gemnasium.com/badges/github.com/pdvend/kronos.svg)](https://gemnasium.com/github.com/pdvend/kronos)
[![Code Climate](https://codeclimate.com/github/pdvend/kronos/badges/gpa.svg)](https://codeclimate.com/github/pdvend/kronos)

This project allows you to use a scheduler with well defined concepts of runners, storage and tasks. It can work in various storage engines, like memory, redis, disk, database, etc. Also, it supports running in synchronous or asynchronous flows.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kronos-ruby'
```

And then execute:

`$ bundle`

Or install it yourself as:

`$ gem install kronos-ruby`


## Usage

```ruby
# Define your environment preferences (runner and storage) and register your tasks
Kronos
  .config
  .runner(Kronos::Runner::Synchronous) # or .runner(Kronos::Runner::Asynchronous)
  .storage(Kronos::Storage::InMemory)
  .logger(Kronos::Logger::Stdout) # or .logger(Kronos::Logger::Slack, "Your Slack Webhook URL here")
  .register(:say_good_morning, '8am') { puts 'Good Morning, Team!' }
  .register(:wish_happy_weekend, 'friday, 6pm') { puts 'Happy Weekend, Team!' }
  # ...

# Then start Kronos (This method can be sync or async, acording to the runner you selected)
Kronos.start
```

### Web dashboard
To view Krono's web dashboard, simply mount it into your Rack stack:
```ruby
mount Kronos::Web::App, at: '/kronos-dashboard'
```

## Developing
- Clone this repository
- Run `bin/setup` to install dependencies
- You can also run `bin/console` to start an iteractive console to test Kronos
- To install this gem onto your local machine, run `bundle exec rake install`.
- To release a new version, update `lib/version.rb` and [CHANGELOG.md](/CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdvend/kronos.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
