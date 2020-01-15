Ruby language implementation of [Informed](../README.md), an event-logging library that helps you understand what's happening in your application.

## Usage

### Install

Add this line to your application's Gemfile:

```ruby
gem 'informed', '~> 1.0'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```
gem install informed
```

### Instrument

```ruby
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
#  I, [2017-07-05T18:27:13.431695 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>true, :fanciness=>12}, :status=>:starting}
#  I, [2017-07-05T18:27:13.431780 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>true, :fanciness=>12}, :status=>:done, :result=>"so fancy"}
#  => "so fancy"
FancyService.new(fanciness: 12).do_something(force: true)
#  I, [2017-07-05T18:27:57.612778 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>true, :force=>true, :fanciness=>12}, :status=>:starting}
#  I, [2017-07-05T18:27:57.612853 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>true, :force=>true, :fanciness=>12}, :status=>:done, :result=>"so fancy"}
#  => "so fancy"
FancyService.new(fanciness: 8).do_something(force: true)
#  I, [2017-07-05T18:28:35.282196 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>false, :force=>true, :fanciness=>8}, :status=>:starting}
#  I, [2017-07-05T18:28:35.282272 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>false, :force=>true, :fanciness=>8}, :status=>:done, :result=>"so fancy"}
#  => "so fancy"
FancyService.new(fanciness: 8).do_something(force: false)
#  I, [2017-07-05T18:29:13.319488 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>false, :force=>false, :fanciness=>8}, :status=>:starting}
#  I, [2017-07-05T18:29:13.319560 #3297]  INFO -- : {:method=>:do_something, :class=>"FancyService", :values=>{:fancy?=>false, :force=>false, :fanciness=>8}, :status=>:done, :result=>"so plain"}
#  => "so plain"
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

## Contributing and Local Development

See the [informed-ruby CONTRIBUTING.md](./CONTRIBUTING.md) for details.
