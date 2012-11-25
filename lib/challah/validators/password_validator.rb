module Challah
  class PasswordValidator < ActiveModel::Validator
    # Check to make sure a valid password and confirmation were set
    def validate(record)
      if record.password_provider?
        if record.new_record? and record.password.to_s.blank? and !record.password_changed?
          record.errors.add :password, :blank
        elsif record.password_changed?
          if record.password.to_s.size < 4
            record.errors.add :password, :invalid_password
          elsif record.password.to_s != record.password_confirmation.to_s
            record.errors.add :password, :no_match_password
          end
        end
      end
    end
  end
end