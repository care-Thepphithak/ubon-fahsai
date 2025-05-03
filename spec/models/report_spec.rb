require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:user) { create(:user) }
  let(:area) { create(:area) }
  let(:report) { create(:report) }
  let(:reports) { create_list(:report, 3) }

  before do
    allow(Current).to receive(:user).and_return(user)
    area_coordinates = JSON.parse(area.coordinates)
    allow(area).to receive(:coordinates).and_return(area_coordinates)
    create(:area_report, area: area, report: report)
    user.areas << area
  end

  describe 'top_districts_today' do
    it 'returns the districts with the correct report counts for today' do
      result = Report.top_districts_today
      expect(result.first.district).to eq("Test Area Unit")
    end

    it 'does not include reports created outside of today' do
      result = Report.top_districts_today
      expect(result.map(&:district_count).sum).to eq(1)
    end
  end

  describe 'severity_levels_json' do
    describe 'SEVERITY_LEVEL_RANGES' do
      it 'returns the correct maximum severity levels for each severity' do
        expected_result = {
          "เล็กน้อย" => 14,
          "ลุกลาม" => 28,
          "เฝ้าระวัง" => 42,
          "ปานกลาง" => 56,
          "รุนแรง" => 70,
          "รุนแรงมาก" => 84,
          "วิกฤติ" => 98
        }.to_json

        result = Report::SEVERITY_LEVEL_RANGES.transform_values(&:max).to_json

        expect(result).to eq(expected_result)
      end
    end
  end

  # describe '#location_within_responsible_areas?' do
  #   context 'when the report location is within the user areas' do
  #     it 'does not add an error' do
  #       report.lat = 15.245
  #       report.long = 104.860
  #       report.valid?
  #       expect(report.errors[:base]).to be_empty
  #     end
  #   end

  #   context 'when the report location is outside the user areas' do
  #     it 'adds an error' do
  #       report.lat = 16.0
  #       report.long = 105.0
  #       report.valid?
  #       expect(report.errors[:base]).to include("ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ")
  #     end
  #   end
  # end
end
