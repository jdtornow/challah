FactoryGirl.define do

  factory :user, class: User do
    first_name 'Test'
    last_name 'User'
    admin false
    factory :admin do
      admin true
    end
    sequence(:email) { |n| "email#{n}@example.com" }
  end

end
