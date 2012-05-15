require 'helper'

class RoutesTest < ActionDispatch::IntegrationTest
  context "The routing engine" do
    should "have sign-in and sign-out routes" do
      assert_routing({ :method => 'get', :path => '/sign-in' }, { :controller => 'sessions', :action => 'new' })
      assert_routing({ :method => 'get', :path => '/sign-out' }, { :controller => 'sessions', :action => 'destroy' })
      assert_routing({ :method => 'post', :path => '/sign-in' }, { :controller => 'sessions', :action => 'create' })
    end
  end
end