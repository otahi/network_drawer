# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'network_drawer/version'

Gem::Specification.new do |spec|
  spec.name          = 'network_drawer'
  spec.version       = NetworkDrawer::VERSION
  spec.authors       = ['Hiroshi Ota']
  spec.email         = ['otahi.pub@gmail.com']
  spec.summary       = 'Network diagram drawer with json'
  spec.description   = 'Network diagram drawer with json'
  spec.homepage      = 'https://github.com/otahi/network_drawer'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'gviz', '~> 0.3.4'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '0.24.1'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'byebug', '~> 3.4.0'
end
