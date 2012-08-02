# Define some basic factories for testing within our sample app
FactoryGirl.define do
  factory :user do
    first_name                'Test'
    last_name                 'User'
    sequence(:username)       { |n| "user#{n}" }
    sequence(:email)          { |n| "email#{n}@example.com" }
    password                  { 'abc123' }
    password_confirmation     { 'abc123' }
  end
end # end FactoryGirl.define