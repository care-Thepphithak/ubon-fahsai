FactoryBot.define do
  factory :area do
    name { "Test Area Unit" }
    coordinates do
      [
        [ 15.263047, 104.874684 ],
        [ 15.252379, 104.850172 ],
        [ 15.236811, 104.864257 ],
        [ 15.245626, 104.876913 ]
      ].to_json
    end
  end
  factory :area_with_reports, parent: :area do
    name { "Test Area Unit 1" }
  end
end
