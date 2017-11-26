# Informed
![build status](https://api.travis-ci.org/wecohere/informed.svg?branch=primary) &mdash; Released Version: 1.1.0 &mdash; In Development: 1.2.0


Informed improves application debuggability by:
  * Logging which methods were called.
  * Aggregating useful data, such as the result of the call, keyword arguments provided, or the result of related instance methods.
  * Exposing when a method starts and finishes.

Informed does *not*:
  * Format logs. It provides a hash to the logger you provide, and it's up to you to format your logs in a useful manner. This will depend on what log aggregation system you are using.
  * Store logs. You will need to configure your applications logger correctly to ensure logs will actually reach your log aggregator.
  * Provide analytics or performance tuning data. Your log aggregator may be good at that though!

## Usage

Informed is intended as a cross-language tool. The language and feature matrix is as follows:

| | [Ruby](./informed-ruby/README.md) | Python | Node | BrowserJS |
| -- | -- | -- | -- | -- |
| Log calls | Yes | No | No | No |
| Multiple loggers | No | No | No | No |
| Filter by Name | No | No | No | No |

See your languages README for usage and installation information.


## Contributing

Documentation improvements, bug reports, feature requests and patches are welcome on GitHub at https://github.com/wecohere/informed. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to our [Code of Conduct](./CODE_OF_CONDUCT.md).

See [CONTRIBUTING.md](./CONTRIBUTING.md) for further guidance.

## License

This library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
