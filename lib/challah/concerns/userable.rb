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
