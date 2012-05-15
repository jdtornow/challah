require 'helper'

class ControllerTest < ActiveSupport::TestCase
  include Challah

  context "A controller" do
    setup do
      @user = create(:user)
      @controller = MockController.new
    end

    should "be signed out by default" do
      assert_equal false, @controller.send(:current_user?)
    end

    should "have signed_in? and current_user methods" do
      session = Session.create(@user)
      session.save

      assert_equal true, @controller.send(:current_user?)
      assert_equal true, @controller.send(:signed_in?)
      assert_equal @user, @controller.send(:current_user)
    end

    should "redirect to login page if user is not logged in" do
      @controller.request.url = 'http://example.com/protected-page'
      @controller.stubs(:signed_in?).returns(false)
      @controller.expects(:redirect_to)
      @controller.send(:signin_required)

      assert_equal @controller.session[:return_to], 'http://example.com/protected-page'
    end
  end
end