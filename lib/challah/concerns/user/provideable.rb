module Challah
  module UserProvideable
    extend ActiveSupport::Concern

    included do
      after_save :update_modified_providers_after_save
      after_save :clear_cached_providers_after_save
    end

    def method_missing(method, *args)
      method_name = method.to_s

      if method_name =~ /^([a-z]*)_provider\?$/
        return provider?($1)
      elsif method_name =~ /^([a-z]*)_provider$/
        return provider($1)
      end

      super
    end

    def providers
      return @providers if @providers

      @providers = {}

      attributes = self.class.authorization_model.hashable_attributes

      # Grab providers from existing authorization records
      @providers = authorizations.inject({}) do |hash, m|
        hash[m.provider.to_sym] = attributes.inject({}) { |p, a| p[a.to_sym] = m.send(a); p }
        hash
      end

      # Then, grab any provider attributes provided
      provider_attributes.each do |k, v|
        if v.respond_to?(:fetch)
          @providers[k] = v
        end
      end

      @providers
    end

    # Does this user have the given provider name
    def provider?(provider_name)
      !!provider(provider_name)
    end

    def provider(provider_name)
      providers[provider_name.to_sym]
    end

    def provider_attributes
      @provider_attributes ||= Challah.providers.keys.inject({}) { |h, m| h[m] = nil; h }
    end

    def provider_attributes=(value)
      if Hash === value
        @provider_attributes = value.keys.inject({}) do |h, m|
          h[m.to_sym] = (value[m].respond_to?(:symbolize_keys) ? value[m].symbolize_keys : value[m])
          h
        end
      end
    end

    def valid_provider?(provider_name)
      name = provider_name.to_sym

      if Challah.providers.keys.include?(name)
        Challah.providers[name].valid?(self)
      else
        false
      end
    end

    protected

    def clear_cached_providers_after_save
      @providers = nil
    end

    # If password or username was changed, update the authorization record
    def update_modified_providers_after_save
      # Save password provider
      if @password_updated or @username_updated
        Challah.providers[:password].save(self)
        @password_updated = false
        @username_updated = false
        @password = nil
      end

      # Save any other providers
      Challah.custom_providers.each do |name, klass|
        custom_provider_attributes = provider_attributes[name]

        if custom_provider_attributes.respond_to?(:fetch)
          if klass.valid?(self)
            klass.save(self)
          end
        end
      end
    end
  end
end