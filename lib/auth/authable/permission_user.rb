module Auth
  module Authable
    module PermissionUser
      def self.included(base)
        base.extend(AuthableMethods)
      end
    
      module AuthableMethods
        def authable_permission_user
          class_eval do
            validates_presence_of :user_id, :permission_id
            validates_numericality_of :user_id, :permission_id

            belongs_to :user
            belongs_to :permission
          end
        end
      end
    end
  end
end