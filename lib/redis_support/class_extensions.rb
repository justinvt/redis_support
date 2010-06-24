module RedisSupport
  class RedisKeyError < StandardError ; end
  class DuplicateRedisKeyDefinitionError < RedisKeyError ; end
  class InvalidRedisKeyDefinitionError < RedisKeyError ; end

  VAR_PATTERN = /^[A-Z]+(_[A-Z]+)*$/
  STR_PATTERN = /^[a-z_]+$/
  module ClassMethods
    def redis=(connection)
      @redis = RedisSupport.redis_connect(connection)
    end

    def redis
      @redis || RedisSupport.redis
    end
    
    # Goal is to allow a class to declare a redis key/property 
    # The key is a colon delimited string where variables
    # are listed are upper case (underscores inbetween) and
    # non variables are completely lower case (underscores inbetween or appending/prepending)
    #
    # variables cannot be repeated and must start with a letter
    # the key must also start with a nonvariable
    #
    # Examples
    #
    #   redis_key :workpools, "job:JOB_ID:workpools"
    #
    # Returns the redis key.
    def redis_key( name, keystruct )
      if Keys.methods.include? name.to_s
        return
        # raise DuplicateRedisKeyDefinitionError
      end
      
      key = keystruct.split(":")
      
      unless (first = key.shift) =~ STR_PATTERN
        raise InvalidRedisKeyDefinitionError.new "keys must begin with lowercase letters"
      end

      vars, strs = key.inject([[],[]]) do |(vs, ss), token|
        case token
        when VAR_PATTERN
          var = token.downcase
          ss << "\#{#{var}}"
          vs << var
        when STR_PATTERN
          ss << token
        else
          raise InvalidRedisKeyDefinitionError.new "Internal error parsing #{keystruct} : last token : #{token}"
        end
        [vs, ss]
      end

      strs.unshift(first)

      RedisSupport::Keys.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{name.to_s}( #{vars.map {|x| x.to_s }.join(', ')} )
          "#{strs.join(":")}"
        end
      RUBY
    end
  end
end
