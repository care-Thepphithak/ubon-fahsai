FactoryBot.define do
  factory :user_area do
    association :user
    association :area
  end
end
