module Challah
  module Userable

    extend ActiveSupport::Concern

    include UserAttributeable
    include UserAuthenticateable
    include UserAuthorizable
    include UserFindable
    include UserPasswordable
    include UserProvideable
    include UserStatusable

    unless Challah.options[:skip_user_validations]
      include UserValidateable
    end

  end
end
