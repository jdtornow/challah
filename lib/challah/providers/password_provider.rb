module Challah
  class PasswordProvider
    def self.set(options = {})
      user_id = options.fetch(:user_id)
      uid     = options.fetch(:uid, '')
      token   = options.fetch(:token, '')

      if token.to_s.blank?
        authorization = ::Authorization.get({
          user_id:  user_id,
          provider: :password
        })

        if authorization
          token = authorization.token
        end
      else
        token = Challah::Encrypter.encrypt(token)
      end

      ::Authorization.set({
        provider: :password,
        user_id:  user_id,
        uid:      uid,
        token:    token
      })
    end
  end
end