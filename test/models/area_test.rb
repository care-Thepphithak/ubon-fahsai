require "test_helper"

class AreaTest < ActiveSupport::TestCase
  test "should not be valid without a name" do
    area = Area.new(name: nil)
    assert_not area.valid?
    assert_includes area.errors[:name], "โปรดระบุชื่อพื้นที่"
  end

  test "should validate uniqueness of name" do
    area = areas(:one)
    duplicate_area = area.dup
    duplicate_area.name = area.name.upcase
    assert_not duplicate_area.valid?
    assert_includes duplicate_area.errors[:name], "ชื่อพื้นที่นี้มีอยู่แล้ว"
  end

  test "should strip whitespace from name" do
    area = Area.new(name: "  พื้นที่ทดสอบ  ")
    area.valid?
    assert_equal "พื้นที่ทดสอบ", area.name
  end
end
