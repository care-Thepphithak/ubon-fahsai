FactoryBot.define do
  factory :user do
    email_address { "unit.test@example.com" }
    password { "unit.test.password123" }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
