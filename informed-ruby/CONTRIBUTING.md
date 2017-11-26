## Contributing to Informed Ruby
This extends the [Informed Contributor Document](../CONTRIBUTING.md) to add Ruby specific guidance.

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

If you want to  test across all supported ruby versions, make sure you have [`rbenv`](https://github.com/rbenv/rbenv) and [ruby-build](https://github.com/rbenv/ruby-build) installed; then run `bin/setup-matrix` to install all the gems across all the versions and `bin/test-matrix` to run all the tests.

To install this gem on your local machine, run `bundle exec rake install`. 

### Releasing

To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


