FactoryBot.define do
  factory :report do
    lat { "15.2314" }
    long { "104.8567" }
    location_name { "มหาวิทยาลัย" }
    description { "Test Description" }
    severity_level { "รุนแรง" }
    tags { [ "ไฟป่า", "เผาไร่อ้อย" ].to_json }
    created_at { Time.zone.now }

    factory :past_2_days_report do
      created_at { 2.days.ago }
    end
  end
end
