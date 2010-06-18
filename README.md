Redis Support
=============

redis_support is a small library which provides simple support for
common actions for the Redis key-value store. It is not an
object-relational mapper, does not attempt to comprehensively solve
all of your storage problems, and does not make julienne fries.

Key Support
-----------

Redis provides a global keyspace. Most projects specify their keys
using namespaces delimited by colons (:), with variables mixed in at
particular points. For example:

    users:1:email

`redis_support`, when used as a mixin, will provide a simple method to
declare that namespace and access it later.

    class User
      include RedisSupport
      redis_key :email, "users:USER_ID:email"

      attr_accessor :id

      def email
        redis.get Keys.email( self.id )
      end
    end

Helpful exceptions are raised if you try to declare the same namespace
twice - RedisSupport keeps track of all the key definitions your app
wants to use.

Locking Support
---------------

There is also a simple locking mechanism based on SETNX. Locking is
usually unnecessary since Redis operations are atomic and Redis'
MULTI/EXEC/DISCARD gives you the ability to make multiple operations
atomic. But sometimes it's useful - a contrived example -
major_operation will block for up to 30 seconds if another process
attempts to run it at the same time:

    class User
      include RedisSupport
      redis_key :email, "users:USER_ID:email"

      attr_accessor :id

      def major_operation
        redis_lock Keys.email( self.id ) do
          # do my expensive stuff
        end
      end
    end

