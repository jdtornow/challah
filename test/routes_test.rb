require 'helper'

class RoutesTest < ActionDispatch::IntegrationTest
  context "The routing engine" do
    should "have login and logout routes" do
      assert_generates '/login', :controller => 'challah/sessions', :action => 'new'
      assert_generates '/logout', :controller => 'challah/sessions', :action => 'destroy'      
      assert_routing({ :method => 'post', :path => '/login' }, { :controller => 'challah/sessions', :action => 'create' })
    end
  end
end