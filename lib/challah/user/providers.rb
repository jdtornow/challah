module Challah::User
  module Providers
    def authorizations
      ::Authorization.where(user_id: self.id)
    end

    def providers
      @providers ||= authorizations.inject({}) do |hash, m|
        hash[m.provider.to_sym] = { id: m.id, uid: m.uid, token: m.token }
        hash
      end
    end

    # Does this user have the given provider name
    def provider?(provider_name)
      !!provider(provider_name)
    end

    def provider(provider_name)
      providers[provider_name.to_sym]
    end
  end
end