# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-php-date-formatter/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-php-date-formatter"
  spec.version       = RailsAssetsPhpDateFormatter::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A Javascript datetime formatting and manipulation library using PHP date-time formats."
  spec.summary       = "A Javascript datetime formatting and manipulation library using PHP date-time formats."
  spec.homepage      = "https://github.com/kartik-v/php-date-formatter"
  spec.license       = "BSD-3-Clause"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
