module Challah::User

  module Reflector

    def authorizations_table_name
      @authorizations_table_name ||= authorization_model.table_name
    end

    def authorization_model
      @authorization_model ||= ::Authorization
    end

  end

end