module Challah
  class PasswordProvider
    def self.save(user)
      set(uid: user.username, token: user.password, user_id: user.id, authorization: user.class.authorization_model)
    end

    def self.set(options = {})
      user_id     = options.fetch(:user_id)
      uid         = options.fetch(:uid, '')
      token       = options.fetch(:token, '')
      auth_model  = options.fetch(:authorization, ::Authorization)

      if token.to_s.blank?
        authorization = auth_model.get({
          user_id:  user_id,
          provider: :password
        })

        if authorization
          token = authorization.token
        end
      else
        token = Challah::Encrypter.encrypt(token)
      end

      auth_model.set({
        provider: :password,
        user_id:  user_id,
        uid:      uid,
        token:    token
      })
    end

    def self.valid?(record)
      password_validator = Challah.options[:password_validator]
      password_validator.new(force: true).validate(record)
      record.errors[:password].size.zero?
    end
  end
end