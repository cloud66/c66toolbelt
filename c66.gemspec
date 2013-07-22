# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'c66/utils/version'

Gem::Specification.new do |spec|
  spec.name          = "c66"
  spec.version       = C66::Utils::VERSION
  spec.authors       = ["Cloud 66"]
  spec.email         = ["hello@cloud66.com"]
  spec.description   = "See https://www.cloud66.com for more info"
  spec.summary       = "Cloud 66 Toolbelt"
  spec.homepage      = "https://www.cloud66.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.3"
  spec.add_dependency "rake", "~> 10.1.0"
  spec.add_dependency "thor", "~> 0.18.1"
  spec.add_dependency "oauth2", "~> 0.9.2"
  spec.add_dependency "json", "~> 1.7.7"
  spec.add_dependency "httparty", "~> 0.11.0"
end
