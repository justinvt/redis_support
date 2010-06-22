require File.dirname(__FILE__) + '/helper'

context "Redis Support setup" do
  setup do
    RedisSupport.redis = "localhost:9736"
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
    TestClass.redis.flushall
    @test_class = TestClass.new
  end

  test "redis connection works as expected" do
    assert_equal @test_class.redis, TestClass.redis
    assert_equal "OK", @test_class.redis.set("superman", 1)
    assert_equal "1", @test_class.redis.get("superman")
  end

  test "redis connections changes as expected" do
    TestClass.redis = "localhost:6379"
    assert_equal @test_class.redis, TestClass.redis
    @test_class.redis = "localhost:9736"
    assert_equal @test_class.redis, TestClass.redis
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
    assert_raise(RedisSupport::DuplicateRedisKeyDefinitionError) do
      TestClass.redis_key :test_var, "this:should:fail"
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
end
