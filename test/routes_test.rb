require 'helper'

class RoutesTest < ActionDispatch::IntegrationTest
  context "The routing engine" do
    should "have sign in and out routes" do
      assert_generates '/sign-in', :controller => 'auth/sessions', :action => 'new'
      assert_generates '/sign-out', :controller => 'auth/sessions', :action => 'destroy'      
      assert_routing({ :method => 'post', :path => '/sign-in' }, { :controller => 'auth/sessions', :action => 'create' })
    end
  end
end