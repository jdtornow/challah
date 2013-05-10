require 'helper'

class AuthorizationTest < ActiveSupport::TestCase

  context "The Authorization class" do

    should "have a list of attributes that are hashable" do
      expected_columns = %w( id uid token expires_at ).sort

      assert_equal expected_columns, Authorization.hashable_attributes.sort
    end

  end

end