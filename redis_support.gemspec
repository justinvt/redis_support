# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{redis_support}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian P O'Rourke", "John Le"]
  s.date = %q{2010-06-23}
  s.description = %q{Module for adding redis functionality to classes: simple key namespacing and locking and connections}
  s.email = %q{dolores@doloreslabs.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "lib/redis_support.rb",
     "lib/redis_support/class_extensions.rb",
     "lib/redis_support/locks.rb"
  ]
  s.homepage = %q{http://github.com/dolores/redis_support}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Redis Support module}
  s.test_files = [
    "test/helper.rb",
     "test/test_redis_support.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>, [">= 1.0.4"])
    else
      s.add_dependency(%q<redis>, [">= 1.0.4"])
    end
  else
    s.add_dependency(%q<redis>, [">= 1.0.4"])
  end
end

