# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'settings_yaml/version'

Gem::Specification.new do |spec|
  spec.name          = 'settings_yaml'
  spec.version       = SettingsYaml::VERSION
  spec.authors       = ['Anton Styagun']
  spec.email         = ['anton@jetruby.com']

  spec.summary       = %q{Store Rails settings in YAML files.}
  spec.homepage      = 'https://github.com/jetruby/settings_yaml'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hashie', '~> 3.4'
  spec.add_dependency 'activesupport', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'test_construct', '~> 2.0'
end
