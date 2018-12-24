# -*- encoding: utf-8 -*-
# stub: jquery-timepicker-rails 1.11.10 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-timepicker-rails".freeze
  s.version = "1.11.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tanguy Krotoff (jQuery plugin by Jon Thornton)".freeze, "Fabio Cantoni".freeze]
  s.date = "2017-03-22"
  s.description = "A jQuery timepicker plugin inspired by Google Calendar".freeze
  s.email = ["tkrotoff@gmail.com".freeze]
  s.homepage = "https://github.com/cover/jquery-timepicker-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "jquery-timepicker packaged for the Rails 3.1+ asset pipeline".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.1.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
