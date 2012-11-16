module Challah
  # Plugins are used to extend the functionality of Challah.
  module Plugins
    # A simple DSL for registering a plugin
    class Plugin
      attr_reader :active_record, :action_controller, :user_extensions, :user_init_methods

      def initialize
        @active_record ||= []
        @action_controller ||= []
        @user_extensions ||= []
        @user_init_methods ||= []
      end

      # When active_record or action_controller is loaded, run the given block
      def on_load(framework, &block)
        return unless [ :active_record, :action_controller ].include?(framework)
        instance_variable_get("@#{framework}") << block
      end

      # Pass a module name to include it in the base User model after challah_user
      # is run
      def extend_user(module_name, init_method = nil)
        @user_extensions << module_name
        @user_init_methods << init_method unless init_method.nil?
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

  # Loop through all registered plugins and extend User functionality.
  def self.include_user_plugins!
    Challah.plugins.values.each do |plugin|
      plugin.user_extensions.each do |mod|
        ::User.send(:extend, mod)
      end

      plugin.user_init_methods.each do |method_name|
        ::User.send(method_name)
      end
    end
  end
end