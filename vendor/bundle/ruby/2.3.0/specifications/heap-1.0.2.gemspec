# -*- encoding: utf-8 -*-
# stub: heap 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "heap".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Victor Costan".freeze]
  s.date = "2016-04-07"
  s.description = "Implements Heap's server-side API".freeze
  s.email = "victor@heapanalytics.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "http://github.com/heap/heap-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Heap server-side API client".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>.freeze, [">= 0.8.11"])
      s.add_runtime_dependency(%q<faraday_middleware>.freeze, [">= 0.8.0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0.8.10"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 2.0.1"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 5.8.4"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 3.12"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0.11.2"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0.8.7.6"])
    else
      s.add_dependency(%q<faraday>.freeze, [">= 0.8.11"])
      s.add_dependency(%q<faraday_middleware>.freeze, [">= 0.8.0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0.8.10"])
      s.add_dependency(%q<jeweler>.freeze, [">= 2.0.1"])
      s.add_dependency(%q<minitest>.freeze, [">= 5.8.4"])
      s.add_dependency(%q<rdoc>.freeze, [">= 3.12"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0.11.2"])
      s.add_dependency(%q<yard>.freeze, [">= 0.8.7.6"])
    end
  else
    s.add_dependency(%q<faraday>.freeze, [">= 0.8.11"])
    s.add_dependency(%q<faraday_middleware>.freeze, [">= 0.8.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0.8.10"])
    s.add_dependency(%q<jeweler>.freeze, [">= 2.0.1"])
    s.add_dependency(%q<minitest>.freeze, [">= 5.8.4"])
    s.add_dependency(%q<rdoc>.freeze, [">= 3.12"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0.11.2"])
    s.add_dependency(%q<yard>.freeze, [">= 0.8.7.6"])
  end
end
