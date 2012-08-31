require 'helper'

class TestPlugins < ActiveSupport::TestCase
  include Challah

  class PluginContext
    def self.setup_active_record
    end

    def self.setup_controllers
    end
  end

  context "The plugin loader" do
    should "be able to load a plugin and any dependencies" do
      assert_equal Hash.new, Challah.plugins

      Challah.register_plugin :tester do
        on_load :active_record do
          PluginContext.setup_active_record
        end

        on_load :action_controller, do
          PluginContext.setup_controllers
        end
      end

      assert_equal true, Challah.plugins.has_key?(:tester)
      assert_equal 1, Challah.plugins[:tester].active_record.size
      assert_equal 1, Challah.plugins[:tester].action_controller.size

      PluginContext.expects(:setup_active_record).once
      PluginContext.expects(:setup_controllers).once

      Challah::Engine.setup_active_record!
      Challah::Engine.setup_action_controller!
    end
  end
end