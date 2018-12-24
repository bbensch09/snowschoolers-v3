# -*- encoding: utf-8 -*-
# stub: rails-assets-php-date-formatter 1.3.5 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-php-date-formatter".freeze
  s.version = "1.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["rails-assets.org".freeze]
  s.date = "2018-07-14"
  s.description = "A Javascript datetime formatting and manipulation library using PHP date-time formats.".freeze
  s.homepage = "https://github.com/kartik-v/php-date-formatter".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "A Javascript datetime formatting and manipulation library using PHP date-time formats.".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
