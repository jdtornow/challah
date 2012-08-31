require 'helper'

class TestPlugins < ActiveSupport::TestCase
  include Challah

  class PluginContext
    def self.setup_active_record
    end

    def self.setup_controllers
    end
  end

  module UserStuff
    def set_me_up
      include AndMore
    end

    module AndMore
      def hey_baller
        "whatsup"
      end
    end
  end

  context "The plugin loader" do
    should "be able to load a plugin and any dependencies" do
      assert_equal false, Challah.plugins.has_key?(:tester)

      Challah.register_plugin :tester do
        on_load :active_record do
          PluginContext.setup_active_record
        end

        on_load :action_controller do
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

    should "be able to include a module when loading Challah::User" do
      assert_equal false, ::User.included_modules.include?(UserStuff::AndMore)

      Challah.register_plugin :user_mods do
        extend_user UserStuff, :set_me_up
      end

      Challah.include_user_plugins!

      assert_equal true, ::User.included_modules.include?(UserStuff::AndMore)

      assert_equal "whatsup", ::User.new().hey_baller
    end
  end
end