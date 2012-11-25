module Challah::User
  module Attributes
    # Returns true if this user is active, and should be able to log in. If
    # the active column is false, the user will not be able to authenticate
    def active?
      !!self.active
    end

    # First name and last name together
    def name
      "#{first_name} #{last_name}".strip
    end

    # shortened name, just includes the first name and last initial
    def small_name
      "#{first_name.to_s.titleize} #{last_name.to_s.first.upcase}."
    end

    # Is this user valid and ready for a user session?
    #
    # Override this method if you need to check for a particular configuration on each page request.
    def valid_session?
      self.active?
    end
  end
end