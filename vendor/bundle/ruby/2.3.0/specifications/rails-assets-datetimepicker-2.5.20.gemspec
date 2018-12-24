# -*- encoding: utf-8 -*-
# stub: rails-assets-datetimepicker 2.5.20 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-datetimepicker".freeze
  s.version = "2.5.20"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["rails-assets.org".freeze]
  s.date = "2018-03-22"
  s.description = "".freeze
  s.homepage = "http://xdsoft.net/jqplugins/datetimepicker".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails-assets-jquery>.freeze, [">= 1.7.2"])
      s.add_runtime_dependency(%q<rails-assets-jquery-mousewheel>.freeze, [">= 3.1.13"])
      s.add_runtime_dependency(%q<rails-assets-php-date-formatter>.freeze, [">= 1.3.3"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails-assets-jquery>.freeze, [">= 1.7.2"])
      s.add_dependency(%q<rails-assets-jquery-mousewheel>.freeze, [">= 3.1.13"])
      s.add_dependency(%q<rails-assets-php-date-formatter>.freeze, [">= 1.3.3"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails-assets-jquery>.freeze, [">= 1.7.2"])
    s.add_dependency(%q<rails-assets-jquery-mousewheel>.freeze, [">= 3.1.13"])
    s.add_dependency(%q<rails-assets-php-date-formatter>.freeze, [">= 1.3.3"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
