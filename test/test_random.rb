require 'helper'

class TestRandom < Test::Unit::TestCase
  should "be able to provide a random string" do
    result = Auth::Random.token(25)
    
    assert_not_nil result
    assert_equal 25, result.size
  end 
end