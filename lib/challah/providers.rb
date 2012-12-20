module Challah
  module Providers
    # Get a list of all authorization providers other than password provider
    def custom_providers
      providers.reject { |k, v| k == :password }
    end

    # Register a new authorization provider.
    #
    # Usage:
    #
    #     Challah.register_provider(:facebook, FacebookProvider)
    def register_provider(name, klass)
      @providers[name] = klass
    end

    # Get the list of all authorization providers that have been registered.
    def providers
      @providers.dup
    end
  end
end