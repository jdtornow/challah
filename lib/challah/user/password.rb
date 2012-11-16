module Challah::User
  module Password
    # Set the password and password_confirmation in one shortcut method.
    def password!(new_password)
      self.password = new_password
      self.password_confirmation = new_password
    end

    # Set a password for this user
    def password=(value)
      if value.to_s.blank?
        @password = nil
        @password_updated = false
      else
        @password = value
        @password_updated = true
      end
    end

    # Set the confirmation when changing a password
    def password_confirmation=(value)
      @password_confirmation = value
    end

    # Was the password updated
    def password_changed?
      !!@password
    end
  end
end