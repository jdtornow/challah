module Challah
  class PasswordProvider
    def self.set(options = {})
      user_id = options.fetch(:user_id)
      uid     = options.fetch(:uid, '')
      token   = options.fetch(:token, '')

      token = Challah::Encrypter.encrypt(token)

      ::Authorization.set({
        provider: :password,
        user_id:  user_id,
        uid:      uid,
        token:    token
      })
    end
  end
end