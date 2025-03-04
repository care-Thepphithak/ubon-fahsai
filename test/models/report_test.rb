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

  test "count_today should return the correct count" do
    Report.delete_all

    report_today = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: Time.zone.today.beginning_of_day
    )
  ]

    assert_equal report_today.count, Report.count_today
  end

  test "count_yesterday should return the correct count" do
    Report.delete_all

    report_yesterday = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: 1.day.ago.beginning_of_day
    )
    ]

    assert_equal report_yesterday.count, Report.count_yesterday
  end


  test "count_harmful_today should return correct count" do
    Report.delete_all

    # Create a harmful report for today
    harmful_today = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: Time.zone.today.beginning_of_day
    )
    ]

    assert_equal harmful_today.count, Report.count_harmful_today
  end

  test "count_harmful_yesterday should return correct count" do
    Report.delete_all

    # Create a non-harmful report for yesterday
    harmful_yesterday = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: 1.days.ago.beginning_of_day
    )
    ]

    assert_equal harmful_yesterday.count, Report.count_harmful_yesterday
  end

  test "count_harmful_reports should return correct count" do
    Report.delete_all

    harmful_report = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: Time.zone.today.beginning_of_day
    )
  ]

    assert_equal harmful_report.count, Report.count_harmful_reports
  end

  # test "top_districts should return unique districts with correct count" do
  #   Report.delete_all
  #   # Create test data directly in the test
  #   report1 = Report.create!(
  #     location_name: "จังหวัดสมุทรปราการ",
  #     severity_level: "วิกฤติ",
  #     created_at: Time.zone.today.beginning_of_day
  #   )
  #   report2 = Report.create!(
  #     location_name: "จังหวัดสมุทรปราการ",
  #     severity_level: "วิกฤติ",
  #     created_at: Time.zone.today.beginning_of_day
  #   )
  #   report3 = Report.create!(
  #     location_name: "จังหวัดสมุทรปราการ",
  #     severity_level: "วิกฤติ",
  #     created_at: Time.zone.today.beginning_of_day
  #   )
  #   report4 = Report.create!(
  #     location_name: "จังหวัดสมุทรปราการ",
  #     severity_level: "วิกฤติ",
  #     created_at: Time.zone.today.beginning_of_day
  #   )
  #   report5 = Report.create!(
  #     location_name: "จังหวัดกรุงเทพมหานคร",
  #     severity_level: "ปกติ",
  #     created_at: Time.zone.today.beginning_of_day
  #   )

  #   puts Report.inspect
  #   puts "************************"

  #   # Now test the top_districts method
  #   top_districts = Report.top_districts.map { |report| { district: report.district, district_count: report.district_count } }


  #   puts top_districts.inspect
  #   puts "============================*********"

  #   # There should be two districts in the result, as we only count today’s reports
  #   assert_equal 2, top_districts.length

  #   # Assert the correct district names and counts
  #   assert_equal "สมุทรปราการ", top_districts.first.district
  #   assert_equal 4, top_districts.first.district_count.to_i  # 4 reports for "สมุทรปราการ"

  #   assert_equal "กรุงเทพมหานคร", top_districts.second.district
  #   assert_equal 1, top_districts.second.district_count.to_i  # 1 report for "กรุงเทพมหานคร"
  # end
end
