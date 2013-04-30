# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pushapp/version'

Gem::Specification.new do |spec|
  spec.name          = 'pushapp'
  spec.version       = Pushapp::VERSION
  spec.authors       = ["Yury Korolev"]
  spec.email         = ["yurykorolev@me.com"]
  spec.description   = %q{Push your App}
  spec.summary       = %q{Push your App}
  spec.homepage      = 'https://github.com/anjlab/pushapp'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
end
