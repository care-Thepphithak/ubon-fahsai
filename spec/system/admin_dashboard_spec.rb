require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'
  fixtures :reports
  fixtures :areas

  TODAY_REPORTS = []
  HARMFUL_REPORTS = []
  ALL_REPORTS = []

  context "When user is an admin and already_logged_in and there are reports today" do
    let(:admin_status) { true }

    before do
      user_logs_in_with_valid_credential

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
    end

    it "displays the admin dashboard page" do
      expect(page).to have_content("Admin")
    end

    it "displays the number of reports today" do
      admin_sees_total_reports_number_equal_to(TODAY_REPORTS.length)
    end

    it "displays the number of harmful reports" do
      admin_sees_harmful_reports_number_equal_to(HARMFUL_REPORTS.length)
    end

    it "displays list of today's reports" do
      admin_sees_list_of_reports TODAY_REPORTS
    end

    it "displays list of all reports" do
      admin_selects_filter_all_reports
      admin_sees_list_of_reports ALL_REPORTS
    end
  end
end


# bundle exec rspec spec/system/admin_dashboard_spec.rb
