module Challah
  # Plugins are used to extend the functionality of Challah.
  module Plugins
    # A simple DSL for registering a plugin
    class Plugin
      attr_accessor :active_record, :action_controller

      def initialize
        @active_record ||= []
        @action_controller ||= []
      end

      # When active_record or action_controller is loaded, run the given block
      def on_load(framework, &block)
        return unless [ :active_record, :action_controller ].include?(framework)
        self.send(framework) << block
      end
    end

    # Register a new plugin.
    def register_plugin(name, &block)
      plugin = Plugin.new
      plugin.instance_eval(&block)
      @plugins[name] = plugin
    end

    # Get the list of all plugins
    def plugins
      @plugins
    end
  end
end