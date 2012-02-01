require 'helper'

class RoutesTest < ActionDispatch::IntegrationTest
  context "The routing engine" do
    should "have sign in and out routes" do
      assert_generates '/sign-in', :controller => 'challah/sessions', :action => 'new'
      assert_generates '/sign-out', :controller => 'challah/sessions', :action => 'destroy'      
      assert_routing({ :method => 'post', :path => '/sign-in' }, { :controller => 'challah/sessions', :action => 'create' })
    end
  end
end