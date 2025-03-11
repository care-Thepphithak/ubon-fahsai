require "test_helper"

class ReportTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)

    Current.session = Session.new(user: @user)
  end

  test "validates presence of severity_level in predefined levels" do
    report = Report.new(
      location_name: "ชื่อสถานที่",
      severity_level: "เล็กน้อย",
      lat: "15.2314",
      long: "104.8567"
    )
    assert report.valid?

    report.severity_level = "ระดับผิด"
    assert_not report.valid?
    assert_includes report.errors[:severity_level], "is not included in the list"
  end

  test "count_today should return the correct count" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all

    report_today = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: Time.zone.today.beginning_of_day,
      lat: "15.2314",
      long: "104.8567"
    )
  ]

    assert_equal report_today.count, Report.count_today
  end

  test "count_yesterday should return the correct count" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all

    report_yesterday = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: 1.day.ago.beginning_of_day,
      lat: "15.2314",
      long: "104.8567"
    )
    ]

    assert_equal report_yesterday.count, Report.count_yesterday
  end


  test "count_harmful_today should return correct count" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all

    # Create a harmful report for today
    harmful_today = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: Time.zone.today.beginning_of_day,
      lat: "15.2314",
      long: "104.8567"
      )
    ]

    assert_equal harmful_today.count, Report.count_harmful_today
  end

  test "count_harmful_yesterday should return correct count" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all

    # Create a non-harmful report for yesterday
    harmful_yesterday = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: 1.days.ago.beginning_of_day,
      lat: "15.2314",
      long: "104.8567"
    )
    ]

    assert_equal harmful_yesterday.count, Report.count_harmful_yesterday
  end

  test "count_harmful_reports should return correct count" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all

    harmful_report = [ Report.create!(
      location_name: "จังหวัดสมุทรปราการ",
      severity_level: "วิกฤติ",
      created_at: Time.zone.today.beginning_of_day,
      lat: "15.2314",
      long: "104.8567"
    )
  ]

    assert_equal harmful_report.count, Report.count_harmful_reports
  end

  test "top_districts returns sorted districts by report count" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.destroy_all

    area1 = Area.create!(name: "อำเภอเมือง", coordinates: [ [ 15.2313, 104.8567 ], [ 15.2314, 104.8568 ], [ 15.2315, 104.8568 ], [ 15.2315, 104.8567 ], [ 15.2313, 104.8567 ] ])
    area2 = Area.create!(name: "อำเภอวารินชำราบ", coordinates: [ [ 15.2313, 104.8567 ], [ 15.2314, 104.8568 ], [ 15.2315, 104.8568 ], [ 15.2315, 104.8567 ], [ 15.2313, 104.8567 ] ])

    report1 = Report.create!(
      location_name: "สถานที่ในอำเภอเมือง",
      severity_level: "วิกฤติ",
      lat: "15.2314",
      long: "104.8567",
      created_at: Time.zone.today.noon
    )

    report2 = Report.create!(
      location_name: "สถานที่ในอำเภอเมืองอีกแห่ง",
      severity_level: "รุนแรง",
      lat: "15.2314",
      long: "104.8567",
      created_at: Time.zone.today.noon
    )

    report3 = Report.create!(
      location_name: "สถานที่ในอำเภอวาริน",
      severity_level: "วิกฤติ",
      lat: "15.2314",
      long: "104.8567",
      created_at: Time.zone.today.noon
    )

    AreaReport.create!(area: area1, report: report1)
    AreaReport.create!(area: area1, report: report2)
    AreaReport.create!(area: area2, report: report3)

    results = Report.top_districts

    mapped_results = results.map { |r| [ r.district, r.district_count.to_i ] }

    assert_equal 2, results.size
    assert_equal [ [ "อำเภอเมือง", 2 ], [ "อำเภอวารินชำราบ", 1 ] ], mapped_results
  end

  test "tags_must_be_valid adds error for invalid tags" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all

    report = Report.new(tags: [ "invalid_tag" ])
    report.valid?
    assert_includes report.errors[:tags], "มีค่าไม่ถูกต้อง"
  end

  test "tags_must_be_valid allows valid tags" do
    AreaReport.where(report_id: Report.pluck(:id)).delete_all
    Report.delete_all
    report = Report.new(tags: [ "ไฟป่า" ])
    report.valid?
    assert_empty report.errors[:tags]
  end
end
