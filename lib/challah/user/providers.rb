module Challah::User
  module Providers
    def authorizations
      return [] if new_record?
      ::Authorization.where(user_id: self.id)
    end

    def providers
      return @providers if @providers

      @providers = {}

      # Grab providers from existing authorization records
      @providers = authorizations.inject({}) do |hash, m|
        hash[m.provider.to_sym] = { id: m.id, uid: m.uid, token: m.token }
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
  end
end