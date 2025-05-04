require "rails_helper"

describe Area do
  let(:area) { create(:area) }

  describe "scopes sorted_by_created_at" do
    it "should returns areas sorted by created_at in descending order" do
      older_area = create(:area, name: "older area", created_at: 2.days.ago)
      newer_area = create(:area, name: "newer area", created_at: 1.day.ago)

      result = Area.sorted_by_created_at
      expect(result.first).to eq(newer_area)
      expect(result.offset(1).first).to eq(older_area)
    end
  end

  describe "validations" do
    it "should validates presence of name" do
      area.name = nil
      area.valid?
      expect(area.errors[:name]).to include("โปรดระบุชื่อพื้นที่")
    end

    it "should validates uniqueness of name" do
      duplicate_area = build(:area, name: area.name)
      duplicate_area.valid?
      expect(duplicate_area.errors[:name]).to include("ชื่อพื้นที่นี้มีอยู่แล้ว")
    end

    it "should validates presence of coordinates" do
      area.coordinates = nil
      area.valid?
      expect(area.errors[:coordinates]).to include("โปรดระบุพิกัดของพื้นที่")
    end
  end

  describe "callbacks" do
    it "strips whitespace from name before validation" do
      area.name = "  Test Area  "
      area.valid?
      expect(area.name).to eq("Test Area")
    end
  end
end
