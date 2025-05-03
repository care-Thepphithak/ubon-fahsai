FactoryBot.define do
  factory :session do
    user { association :user }
  end
end
