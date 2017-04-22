# Informed
![build status](https://travis-ci.org/zincmade/informed.svg?branch=primary)

Informed improves application debuggability by:
* Logging which methods were called.
* Aggregating useful data, such as the result of the call, keyword arguments provided, or the result of related instance methods
* Exposing when a method starts and finishes

Informed does *not*:
* Format logs. It provides a hash to the logger you provide, and it's up to you
  to format your logs in a useful manner. This will depend on what log
  aggregation system you are using.
* Store logs. You will need to configure your applications logger correctly to
  ensure logs will actually reach your log aggregator.
* Provide useful analytics or performance tuning data. Logs are for informing
  your incident detection system, debugging, and auditing. While one may get
  *some* amount of metrics utility out of them, products oriented towards
  exposing the insights you are looking for are generally better equipped for
  that.


## Usage

### Install

Add this line to your application's Gemfile:

```ruby
gem 'informed', '~> 1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install informed

### Instrument

```

class FancyService
  attr_accessor :fanciness
  include Informed
  def initialize(fanciness:)
    self.fanciness = fanciness
  end

  def do_something(force: false)
    if fancy? || force
      do_it_fancy
    else
      do_it_plain
    end
  end
  inform_on :do_something, level: :info,
                           also_log: { result: true, values: [:fancy?, :force, :fanciness]}

  def fancy?
    fanciness > 10
  end

  def do_it_plain
    "so plain"
  end

  def do_it_fancy
    "so fancy"
  end
end

FancyService.new(fanciness: 12).do_something
#  I, [2017-04-04T19:46:05.256753 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :fanciness=>12}, :status=>:starting}
#  I, [2017-04-04T19:46:05.256896 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :fanciness=>12}, :status=>:done, :result=>"so fancy"}
#  => "so fancy"
FancyService.new(fanciness: 12).do_something(force: true)
#  I, [2017-04-04T19:46:09.043051 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :force=>true, :fanciness=>12}, :status=>:starting}
#  I, [2017-04-04T19:46:09.043159 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :force=>true, :fanciness=>12}, :status=>:done, :result=>"so fancy"}
#  => "so fancy"
FancyService.new(fanciness: 8).do_something(force: true)
#  I, [2017-04-04T19:46:17.968960 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>true, :fanciness=>8}, :status=>:starting}
#  I, [2017-04-04T19:46:17.969066 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>true, :fanciness=>8}, :status=>:done, :result=>"so fancy"}
#  => "so fancy"
FancyService.new(fanciness: 8).do_something(force: false)
#  I, [2017-04-04T19:49:10.485462 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>false, :fanciness=>8}, :status=>:starting}
#  I, [2017-04-04T19:49:10.485596 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>false, :fanciness=>8}, :status=>:done, :result=>"so plain"}
# => "so plain"
```

### Configure

While we default to logging to standard out, Informed is Logger-agnostic. You
may provide a logger to informed that is interface compatible with the Logger
class in the Ruby standard library.

To do so either:
* Set `Informed.logger` to your application logger. (Rails Example:
  `Informed.logger = Rails.logger`)
* Define an instance method `logger` on the informed upon class and have it
  return whatever logger you want.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/zincmade/informed. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

