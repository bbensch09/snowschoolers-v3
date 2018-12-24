# -*- encoding: utf-8 -*-
# stub: exception_notification 4.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "exception_notification".freeze
  s.version = "4.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.11".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jamis Buck".freeze, "Josh Peek".freeze]
  s.date = "2017-08-12"
  s.email = "smartinez87@gmail.com".freeze
  s.homepage = "https://smartinez87.github.io/exception_notification/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Exception notification for Rails apps".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionmailer>.freeze, ["< 6", ">= 4.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.0"])
      s.add_development_dependency(%q<rails>.freeze, ["< 6", ">= 4.0"])
      s.add_development_dependency(%q<resque>.freeze, ["~> 1.2.0"])
      s.add_development_dependency(%q<sidekiq>.freeze, ["< 3.2.2", "~> 3.0.0"])
      s.add_development_dependency(%q<tinder>.freeze, ["~> 1.8"])
      s.add_development_dependency(%q<httparty>.freeze, ["~> 0.10.2"])
      s.add_development_dependency(%q<mocha>.freeze, [">= 0.13.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 1.3.4"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8.2"])
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.0.0"])
      s.add_development_dependency(%q<hipchat>.freeze, [">= 1.0.0"])
      s.add_development_dependency(%q<carrier-pigeon>.freeze, [">= 0.7.0"])
      s.add_development_dependency(%q<slack-notifier>.freeze, [">= 1.0.0"])
    else
      s.add_dependency(%q<actionmailer>.freeze, ["< 6", ">= 4.0"])
      s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.0"])
      s.add_dependency(%q<rails>.freeze, ["< 6", ">= 4.0"])
      s.add_dependency(%q<resque>.freeze, ["~> 1.2.0"])
      s.add_dependency(%q<sidekiq>.freeze, ["< 3.2.2", "~> 3.0.0"])
      s.add_dependency(%q<tinder>.freeze, ["~> 1.8"])
      s.add_dependency(%q<httparty>.freeze, ["~> 0.10.2"])
      s.add_dependency(%q<mocha>.freeze, [">= 0.13.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.4"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0.8.2"])
      s.add_dependency(%q<appraisal>.freeze, ["~> 2.0.0"])
      s.add_dependency(%q<hipchat>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<carrier-pigeon>.freeze, [">= 0.7.0"])
      s.add_dependency(%q<slack-notifier>.freeze, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<actionmailer>.freeze, ["< 6", ">= 4.0"])
    s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.0"])
    s.add_dependency(%q<rails>.freeze, ["< 6", ">= 4.0"])
    s.add_dependency(%q<resque>.freeze, ["~> 1.2.0"])
    s.add_dependency(%q<sidekiq>.freeze, ["< 3.2.2", "~> 3.0.0"])
    s.add_dependency(%q<tinder>.freeze, ["~> 1.8"])
    s.add_dependency(%q<httparty>.freeze, ["~> 0.10.2"])
    s.add_dependency(%q<mocha>.freeze, [">= 0.13.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.4"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.8.2"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.0.0"])
    s.add_dependency(%q<hipchat>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<carrier-pigeon>.freeze, [">= 0.7.0"])
    s.add_dependency(%q<slack-notifier>.freeze, [">= 1.0.0"])
  end
end
