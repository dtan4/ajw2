# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ajw2/version'

Gem::Specification.new do |spec|
  spec.name          = "ajw2"
  spec.version       = Ajw2::VERSION
  spec.authors       = ["fujita"]
  spec.email         = ["fujita@tt.cs.titech.ac.jp"]
  spec.summary       = %q{One-Page Modern Web Application Generator}
  spec.description   = %q{One-Page Modern Web Application Generator using Client-Side Centric Model}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-rcov"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "ci_reporter"
end
