require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "redis_support"
    gem.summary = "A Redis Support module"
    gem.description = "Module for adding redis functionality to classes: simple key namespacing and locking and connections"
    gem.email = "dolores@doloreslabs.com"
    gem.homepage = "http://github.com/dolores/redis_support"
    gem.authors = ["Brian P O'Rourke", "John Le"]
    gem.files = Dir['lib/**/*.rb']
    gem.add_dependency "redis", ">= 1.0.4"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "redis_support #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies

task :default => :test
