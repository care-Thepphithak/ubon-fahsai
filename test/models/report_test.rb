require "test_helper"

class ReportTest < ActiveSupport::TestCase
  def setup
    @valid_tags = [ "ไฟป่า", "ไฟไหม้บ้าน" ]
    @invalid_tags = [ "แท็กผิด", "ไม่มีในรายการ" ]
  end

  test "validates presence of severity_level in predefined levels" do
    report = Report.new(severity_level: Report::SEVERITIES.sample, description: "ข้อความทดสอบ")
    assert report.valid?

    report.severity_level = "ระดับผิด"
    assert_not report.valid?
    assert_includes report.errors[:severity_level], "is not included in the list"
  end

  test "validates description length" do
    valid_report = Report.new(description: "a" * 300)
    assert valid_report.valid?

    invalid_report = Report.new(description: "a" * 301)
    assert_not invalid_report.valid?
    assert_includes invalid_report.errors[:description], "is too long (maximum is 300 characters)"
  end
end
