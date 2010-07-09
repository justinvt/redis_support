require File.dirname(__FILE__) + '/helper'

context "Redis Support Setup" do
  setup do
    RedisSupport.redis = "localhost:9736"
    TestClass.redis = nil
    SecondTest.redis = nil
  end

  test "redis is loaded correctly" do
    assert RedisSupport.redis
    assert TestClass.redis
    assert SecondTest.redis
    assert_equal 9736, RedisSupport.redis.client.port
    assert_equal 9736, TestClass.redis.client.port
    assert_equal 9736, SecondTest.redis.client.port
    assert_equal "localhost", TestClass.redis.client.host
    assert_equal RedisSupport.redis, TestClass.redis
  end
end

context "Redis Support" do
  setup do
    RedisSupport.redis = "localhost:9736"
    TestClass.redis = nil
    TestClass.redis.flushall
    @test_class = TestClass.new
  end

  test "redis connection works as expected" do
    assert_equal @test_class.redis, TestClass.redis
    assert_equal "OK", @test_class.redis.set("superman", 1)
    assert_equal "1", @test_class.redis.get("superman")
  end

  test "redis connections changes as expected" do
    TestClass.redis = "localhost:2345"
    assert_equal @test_class.redis.client.port, RedisSupport.redis_connect("localhost:2345").client.port
    assert_equal TestClass.redis.client.port, RedisSupport.redis_connect("localhost:2345").client.port
  end

  test "redis keys are created correctly in normal conditions" do
    assert_equal "test:redis", TestClass::Keys.test_novar
    assert_equal "test:redis:variable", TestClass::Keys.test_var("variable")
    assert_equal "test:redis:variable:id:append", TestClass::Keys.test_vars("variable", "id")
  end

  test "redis key should be able to create key" do
    assert_nothing_raised do
      TestClass.redis_key :whatever, "this_should_work"
    end
  end

  test "redis keys are not created if the keyname was previously used" do
    # assert_raise(RedisSupport::DuplicateRedisKeyDefinitionError) do
    #   TestClass.redis_key :test_var, "this:should:fail"
    # end
    
    # we are currently not using this feature
    assert_nothing_raised do
      TestClass.redis_key :test_var, "this:shouldnot:fail:anymore"
    end
  end

  test "redis key should fail when given incorrect syntax" do
    failure_keys = %w{oh:WE_should:fail oh:WE_:fail oh:_WE:fail oh:WE_903:fail FAILPART:oh:no}
    failure_keys.each do |failure_key|
      assert_raise(RedisSupport::InvalidRedisKeyDefinitionError) do
        TestClass.redis_key :failure, failure_key
      end
    end    
  end

  test "redis keys fails gracefully, syntax error, when key space is fucked" do
    assert_raise(SyntaxError) do
      TestClass.redis_key :failure, "test:redis:VAR:VAR:oops"
    end
  end

  test "redis keys can be redefined" do
    assert_equal "test:redis:variable:id:append", TestClass::Keys.test_vars("variable", "id")

    TestClass.redefine_redis_key :test_vars, "new:definition:redis:key:VAR:ID"
    assert_equal "new:definition:redis:key:variable:id", TestClass::Keys.test_vars("variable", "id")
  end

  test "a nonexistent key when redefined doesn't fail" do
    assert_raise(NoMethodError) do
      TestClass::Keys.test_redefine_notexist("variable", "id")
    end

    TestClass.redefine_redis_key :test_redefine_notexist, "nonexistent:redis:key:VAR:ID"
    assert_equal "nonexistent:redis:key:variable:id", TestClass::Keys.test_redefine_notexist("variable", "id")
  end
end

context "Including Redis Support" do
  setup do
    class Foo
      include RedisSupport
    end
    
    class Bar
      include RedisSupport
    end

    Foo.redis = "localhost:2345"
    Bar.redis = "localhost:3456"

    @foo = Foo.new
  end

  test "return different server definitions when set" do
    RedisSupport.redis = Redis.new(:port => 1234, :host => "localhost")
    assert_equal Foo.redis, Foo.redis # I'm sane, really.
    assert_not_equal Foo.redis, Bar.redis
    assert_not_equal Foo.redis, RedisSupport.redis
    assert_equal @foo.redis, Foo.redis

    assert_raise(NoMethodError) do
      @foo.redis = "localhost:3456" 
    end
  end

  test "same test runs twice in a row (return different server definitions when set)" do
    RedisSupport.redis = Redis.new(:port => 1234, :host => "localhost")
    assert_equal Foo.redis, Foo.redis # I'm sane, really.
    assert_not_equal Foo.redis, Bar.redis
    assert_not_equal Foo.redis, RedisSupport.redis
    assert_equal @foo.redis, Foo.redis

    assert_raise(NoMethodError) do
      @foo.redis = "localhost:3456" 
    end
  end
end


context "Including Redis Support in Module" do
  setup do
    RedisSupport.redis = Redis.new(:port => 9999, :host => "localhost")
    
    module FooBar
      include RedisSupport
      extend self

      redis_key :tester, "testing:include"
    end

    FooBar.redis = "localhost:1234"
  end

  test "the include of RedisSupport in a module" do
    assert_equal 1234, FooBar.redis.client.port
    assert_equal 9999, RedisSupport.redis.client.port
  end
end
