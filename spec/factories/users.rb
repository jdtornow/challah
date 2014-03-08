FactoryGirl.define do

  factory :user, class: User do
    first_name 'Test'
    last_name 'User'
    sequence(:email) { |n| "email#{n}@example.com" }
  end

end
