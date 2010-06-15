require File.dirname(__FILE__) + '/helper'

context "Redis Support" do
  setup do
    @test_class = TestClass.new
  end

  test "redis connection works as expected" do
    assert_equal @test_class.redis, TestClass.redis
    assert_equal "OK", @test_class.use_redis_set
    assert_equal "1", @test_class.redis.get("superman")
  end

  test "redis keys are created correctly in normal conditions" do
    assert_equal "test:redis", @test_class.novar_key
    assert_equal "test:redis:variable", @test_class.var_key
    assert_equal "test:redis:variable:id:append", @test_class.vars_key
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

  test "redis keys are fails gracefully, syntax error, when key space is fucked" do
    assert_raise(SyntaxError) do
      TestClass.redis_key :failure, "test:redis:VAR:VAR:oops"
    end
  end
end
