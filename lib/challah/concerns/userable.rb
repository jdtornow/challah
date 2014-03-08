require_relative "user/attributeable"
require_relative "user/authenticateable"
require_relative "user/authorizable"
require_relative "user/findable"
require_relative "user/passwordable"
require_relative "user/provideable"
require_relative "user/validateable"

module Challah
  module Userable
    extend ActiveSupport::Concern

    include UserAttributeable
    include UserAuthenticateable
    include UserAuthorizable
    include UserFindable
    include UserPasswordable
    include UserProvideable

    unless Challah.options[:skip_user_validations]
      include UserValidateable
    end

    included do
      Challah.include_user_plugins!
    end
  end
end