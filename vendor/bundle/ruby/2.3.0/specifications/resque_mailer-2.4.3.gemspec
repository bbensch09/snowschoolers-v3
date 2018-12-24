# -*- encoding: utf-8 -*-
# stub: resque_mailer 2.4.3 ruby lib

Gem::Specification.new do |s|
  s.name = "resque_mailer".freeze
  s.version = "2.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Plante".freeze]
  s.date = "2017-09-18"
  s.description = "Rails plugin for sending asynchronous email with ActionMailer and Resque.".freeze
  s.email = ["nap@zerosum.org".freeze]
  s.extra_rdoc_files = ["LICENSE".freeze, "CHANGELOG.md".freeze, "README.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "LICENSE".freeze, "README.md".freeze]
  s.homepage = "http://github.com/zapnap/resque_mailer".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Rails plugin for sending asynchronous email with ActionMailer and Resque.".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0"])
      s.add_runtime_dependency(%q<actionmailer>.freeze, [">= 3.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0.6.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 3.0"])
      s.add_dependency(%q<actionmailer>.freeze, [">= 3.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
      s.add_dependency(%q<yard>.freeze, [">= 0.6.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_dependency(%q<actionmailer>.freeze, [">= 3.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<yard>.freeze, [">= 0.6.0"])
  end
end
