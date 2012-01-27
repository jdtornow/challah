# Define some basic factories for testing within our sample app
FactoryGirl.define do
  factory :permission do
    sequence(:name) { |n| "Permission #{n}" }
    key { "sample" }
    description { "This is just a ample permission, it does nothing" }

    factory :admin_permission do
      name "Administrator"
      key "admin"
    end

    factory :users_permission do
      name { "Manage Users" }
      key { "manage_users" }
    end
  end 

  factory :role do
    name { "Sample Role" }
    default_path { "/" }
    description { "Role Description" }

    factory :administrator_role do
      name "Administrator"
      
      after_create do |role| 
        Factory(:admin_permission_role, :role => role)
        Factory(:user_permission_role, :role => role)
      end
    end
    
    factory :default_role do
      name { "Default" }
    end
  end

  factory :admin_permission_role, :class => :permission_role do
    association :permission, :factory => :admin_permission
  end

  factory :user_permission_role, :class => :permission_role do
    association :permission, :factory => :users_permission
  end

  factory :user do
    first_name "Test"
    last_name "User"
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
    password { "abc123" }
    password_confirmation { "abc123" }
    role_id { "1" }

    factory :plain_user do
      first_name { "Plain" }
      sequence(:username) { |n| "plain#{n}" }
      role_id nil
    end
    
    factory :normal_user do
      first_name { "Normal" }
      sequence(:username) { |n| "normal#{n}" }
    end

    factory :admin_user do
      first_name { "Admin" }
      sequence(:username) { |n| "admin#{n}" }
      association :role, :factory => :administrator_role
    end
  end
end # end FactoryGirl.define