# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'informed/version'

Gem::Specification.new do |spec|
  spec.name          = "informed"
  spec.version       = Informed::VERSION
  spec.authors       = ["Zee Spencer"]
  spec.email         = ["zee@zincma.de"]

  spec.summary       = %q{Informs on method calls so you know what your app is doing and why}
  spec.description   = %q{You can't spell Debugging without Logging.}
  spec.homepage      = "https://github.com/zincmade/informed"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.metadata["yard.run"] = "yard" # use "yard" to build full HTML docs.
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "minitest-documentation", "~> 1.0"
end
