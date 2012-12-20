module Challah
  class PasswordProvider
    def self.save(user)
      set(uid: user.username, token: user.password, user_id: user.id)
    end

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

    def self.valid?(user)
      password_validator = Challah.options[:password_validator]
      password_validator.new(force: true).validate(user)
    end
  end
end