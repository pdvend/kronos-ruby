# Kronos
[![Build Status](https://semaphoreci.com/api/v1/pdvend/kronos/branches/master/badge.svg)](https://semaphoreci.com/pdvend/kronos)
[![Coverage Status](https://coveralls.io/repos/github/pdvend/kronos/badge.svg?branch=master)](https://coveralls.io/github/pdvend/kronos?branch=master)

This project allows you to use a scheduler with well defined concepts of runners, storage and tasks. It can work in various storage engines, like memory, redis, disk, database, etc. Also, it supports running in synchronous or asynchronous flows.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kronos'
```

And then execute:

`$ bundle`

Or install it yourself as:

`$ gem install kronos`


## Usage

```ruby
# Define your environment preferences (runner and storage) and register your tasks
Kronos
  .config
  .runner(Kronos::Runner::Synchronous)
  .storage(Kronos::Storage::InMemory)
  .register(:say_good_morning, '8am') { puts 'Good Morning, Team!' }
  .register(:wish_happy_weekend, 'friday, 6pm') { puts 'Happy Weekend, Team!' }
  # ...

# Then start Kronos (This method can be sync or async, acording to the runner you selected)
Kronos.start
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
