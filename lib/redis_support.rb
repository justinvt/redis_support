require 'rubygems'

require 'redis'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/"))
require 'redis_support/class_extensions'
require 'redis_support/locks'

module RedisSupport
  def redis
    if( self.class.respond_to?(:redis) )
      self.class.redis
    else
      @redis || RedisSupport.redis
    end
  end

  def keys
    Keys
  end

  module Keys
    def self.keystructs
      @keystructs ||= []
    end
    
    #returns a string suitable for randomizing a redis key
    def self.random_key_string
      "#{Time.now.to_i}#{rand(10000)}" 
    end
  end

  def self.included(model)
    model.extend ClassMethods
  end

  # Inspired/take from the redis= in Resque
  #
  # Accepts:
  #   1. A 'hostname:port' string
  #   2. A 'hostname:port:db' string (to select the Redis db)
  #   3. An instance of `Redis`, `Redis::Client`
  def self.redis_connect(connection)
    if connection.respond_to? :split
      host, port, db = connection.split(':')
      Redis.new(:host => host,:port => port,:thread_safe => true,:db => db)
    else
      connection
    end
  end

  extend ClassMethods
end
