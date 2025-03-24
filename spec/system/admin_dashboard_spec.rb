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

      AreaReport.create!(area: areas(:one), report: reports(:one))
      AreaReport.create!(area: areas(:one), report: reports(:one))
    end

    it "displays the admin dashboard page" do
      expect(page).to have_content("Admin")
    end

    it "displays the number of reports today" do
      admin_sees_total_reports_number_equal_to 3
    end

    # it "displays the number of harmful reports" do
    #   admin_sees_harmful_reports_number_equal_to(HARMFUL_REPORTS.length)
    # end

    # it "displays list of today's reports" do
    #   admin_sees_list_of_reports TODAY_REPORTS
    # end

    # it "displays list of all reports" do
    #   admin_selects_filter_all_reports
    #   admin_sees_list_of_reports ALL_REPORTS
    # end

    private

    def admin_sees_total_reports_number_equal_to(expected_count)
      actual_count = find('#report_counter').text.to_i
      expect(actual_count).to eq(expected_count)
    end
  end
end


# bundle exec rspec spec/system/admin_dashboard_spec.rb
