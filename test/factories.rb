# Define some basic factories for testing within our sample app
FactoryGirl.define do
  factory :user do
    first_name                'Test'
    last_name                 'User'
    sequence(:email)          { |n| "email#{n}@example.com" }
  end
end # end FactoryGirl.define