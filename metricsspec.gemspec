# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metricsspec/version'

Gem::Specification.new do |spec|
  spec.name          = "metricsspec"
  spec.version       = Metricsspec::VERSION
  spec.authors       = ["Masaki Matsushita"]
  spec.email         = ["glass.saga@gmail.com"]
  spec.summary       = %q{a tool for testing your server's metrics in elasticsearch}
  spec.description   = %q{a tool for testing your server's metrics in elasticsearch}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec"
  spec.add_dependency "elasticsearch"
  spec.add_dependency "jbuilder"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
