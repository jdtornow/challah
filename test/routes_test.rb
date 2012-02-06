require 'helper'

class RoutesTest < ActionDispatch::IntegrationTest
  context "The routing engine" do
    should "have login and logout routes" do
      assert_generates '/login', :controller => 'sessions', :action => 'new'
      assert_generates '/logout', :controller => 'sessions', :action => 'destroy'      
      assert_routing({ :method => 'post', :path => '/login' }, { :controller => 'sessions', :action => 'create' })
    end
  end
end