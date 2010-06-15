require 'rubygems'
require 'test/unit'

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(dir, '..', 'lib'))
$LOAD_PATH.unshift(dir)
require 'redis_support'

##
# much of this was taken directly from the resque test suite
#
#
if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end

#
# start our own redis when the tests start,
# kill it when they end
#
at_exit do
  next if $!

  if defined?(MiniTest)
    exit_code = MiniTest::Unit.new.run(ARGV)
  else
    exit_code = Test::Unit::AutoRunner.run
  end

  pid = `ps -A -o pid,command | grep [r]edis-test`.split(" ")[0]
  puts "Killing test redis server..."
  `rm -f #{dir}/dump.rdb`
  Process.kill("KILL", pid.to_i)
  exit exit_code
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
$redis = Redis.new( :host => 'localhost', :port => 9736, :db => 0, :thread_safe => true ) 

##
# test/spec/mini 3
# http://gist.github.com/25455
# chris@ozmm.org
#
def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  (class << klass; self end).send(:define_method, :name) { name.gsub(/\W/,'_') }
  klass.class_eval &block
end

class TestClass
  include RedisSupport
  
  redis_key :test_novar, "test:redis"
  redis_key :test_var, "test:redis:VAR"
  redis_key :test_vars, "test:redis:VAR_ONE:VAR_TWO:append"
end
