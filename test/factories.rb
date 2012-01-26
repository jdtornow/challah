# Permissions
begin 
  FactoryGirl.define do
    factory :permission do
      name "Tester"
      key "test"
      description "Just a test permission."

      factory :admin_permission do
        name "Administrator"
        key "admin"
      end

      factory :users_permission do
        name "Manage Users"
        key "manage_users"
      end
    end 
  end
rescue FactoryGirl::DuplicateDefinitionError
  # ok, this assumes that in your app you created permissions with these names
end

# Roles
begin
  FactoryGirl.define do
    factory :role do
      name "Sample Role"
      default_path "/"
      description "Role Description"

      factory :default_role do
        name "Default"
      end

      factory :administrator_role do
        name "Administrator"
        after_create do |role| 
          Factory(:admin_permission_role, :role => role)
          Factory(:user_permission_role, :role => role)
        end
      end
    end
  end
rescue FactoryGirl::DuplicateDefinitionError
  # ok, this assumes that in your app you created roles with these names
end

begin
  FactoryGirl.define do
    # Permissions/Roles
    factory :admin_permission_role, :class => :permission_role do
      association :permission, :factory => :admin_permission
    end

    factory :user_permission_role, :class => :permission_role do
      association :permission, :factory => :users_permission
    end
  end
rescue FactoryGirl::DuplicateDefinitionError
  # ok, this assumes that in your app you created permission/roles with these names
end

# Users
begin  
  FactoryGirl.define do
    factory :user do
      first_name "Test"
      last_name "User"
      sequence(:username) { |n| "tester#{n}" }
      email { |a| "#{a.username}@clickhereqc.com" }
      password "test123"
      password_confirmation { |a| a.password }
      association :role, :factory => :default_role

      factory :normal_user do
        first_name "Normal"
        sequence(:username) { |n| "normal#{n}" }
      end

      factory :admin_user do
        first_name "Admin"
        sequence(:username) { |n| "admin#{n}" }
        association :role, :factory => :administrator_role
      end
    end
  end
rescue FactoryGirl::DuplicateDefinitionError
  # ok, this assumes that in your app you created users with these names
end