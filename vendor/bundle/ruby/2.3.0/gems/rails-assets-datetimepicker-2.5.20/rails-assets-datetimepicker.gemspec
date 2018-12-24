# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-datetimepicker/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-datetimepicker"
  spec.version       = RailsAssetsDatetimepicker::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "http://xdsoft.net/jqplugins/datetimepicker"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", ">= 1.7.2"
  spec.add_dependency "rails-assets-jquery-mousewheel", ">= 3.1.13"
  spec.add_dependency "rails-assets-php-date-formatter", ">= 1.3.3"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
