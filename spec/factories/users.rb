FactoryGirl.define do

  factory :user, class: User do
    first_name 'Test'
    last_name 'User'
    factory :admin do
      role_id 1
    end
    sequence(:email) { |n| "email#{n}@example.com" }
  end

end
