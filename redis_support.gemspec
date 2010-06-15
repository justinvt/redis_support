require 'rubygems'

Gem::Specification.new do |s|
  s.name         = 'redis_support'
  s.author       = 'dolores'
  s.email        = 'dolores@doloreslabs.com'
  s.homepage     = 'http://github.com/dolores/redis_support'
  s.version      = '0.1.0'
  s.summary      = "A Redis Support module"
  s.description  = "Module for adding redis functionality to classes: simple key namespacing and locking and connections"
  s.files        = Dir['lib/**/*.rb']
  s.require_path = "lib"
  s.autorequire  = "redis_support"
  s.has_rdoc     = false
  s.add_dependency("redis")
  s.add_dependency("redis-namespace")
end
