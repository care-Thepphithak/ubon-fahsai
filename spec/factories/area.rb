FactoryBot.define do
  factory :area do
    name { "Test Area Unit" }
    coordinates do
      [
        [ -255.1638094, 15.2721763 ],
        [ -255.1160876, 15.2836023 ],
        [ -255.0656191, 15.2622401 ],
        [ -255.0323168, 15.203607 ],
        [ -255.167071, 15.1766038 ],
        [ -255.188872, 15.2161963 ],
        [ -255.1638094, 15.2721763 ]
      ].to_json
    end
  end
  factory :area_with_reports, parent: :area do
    name { "Test Area Unit 1" }
  end
end
