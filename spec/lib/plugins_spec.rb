require 'spec_helper'

module Challah
  # TODO make these specs not look like unit tests
  describe Plugins do

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

    describe ".plugins" do
      it "has a list of plugins" do
        expect(Challah.plugins).to be_kind_of(Hash)
      end
    end

    describe ".register_plugin" do
      it "allows for plugin registratiosn" do
        expect(Challah).to respond_to(:register_plugin)
      end

      context "before registering" do
        it "doesn't contain unregistered plugins" do
          expect(Challah.plugins).to_not include(:tester)
        end
      end

      context "after registering" do
        let(:plugin) { Challah.plugins[:tester] }

        before do
          Challah.register_plugin :tester do
            on_load :active_record do
              PluginContext.setup_active_record
            end

            on_load :action_controller do
              PluginContext.setup_controllers
            end
          end
        end

        it "contains the registered plugin" do
          expect(Challah.plugins).to include(:tester)
        end

        it "has the active record block" do
          expect(plugin.active_record.size).to eq(1)
        end

        it "has the action controller block" do
          expect(plugin.action_controller.size).to eq(1)
        end

        it "registers components with the engine" do
          expect(PluginContext).to receive(:setup_active_record).once
          expect(PluginContext).to receive(:setup_controllers).once

          Engine.setup_active_record!
          Engine.setup_action_controller!
        end
      end

      context "before registering user extensions" do
        it "does not contain extension modules" do
          expect(Challah.user.included_modules).to_not include(UserStuff::AndMore)
        end
      end

      context "after registering user extensions" do
        before do
          Challah.register_plugin :user_mods do
            extend_user UserStuff, :set_me_up
          end

          Challah.include_user_plugins!
        end

        it "contains the extended modules" do
          expect(Challah.user.included_modules).to include(UserStuff::AndMore)
        end

        it "has the methods included in User" do
          expect(Challah.user.new.hey_baller).to eq("whatsup")
        end
      end
    end
  end
end
