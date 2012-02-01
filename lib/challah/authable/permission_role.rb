module Challah
  module AuthablePermissionRole
    def authable_permission_role
      class_eval do
        validates_presence_of :permission_id, :role_id
        validates_numericality_of :permission_id, :role_id
        
        belongs_to :role
        belongs_to :permission
      end
    end
  end
end