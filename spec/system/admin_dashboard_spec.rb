require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'

  context "When user is an admin and already_logged_in and there are reports today" do
    let(:admin_status) { true }
    let(:reports_today) { Report.today }
    let(:total_harmful_reports_today) { Report.today.harmful.count }

    before do
      user_logs_in_with_valid_credential
    end

    it "displays the admin dashboard page" do
      expect(page).to have_content("Admin")
    end

    it "displays the number of reports today" do
      admin_sees_total_reports_number_equal_to reports_today.count
    end

    it "displays the number of harmful reports" do
      admin_sees_harmful_reports_number_equal_to total_harmful_reports_today
    end

    it "displays list of today's reports" do
      admin_sees_list_of_reports reports_today
    end

    # it "displays list of all reports" do
    #   admin_selects_filter_all_reports
    #   admin_sees_list_of_reports ALL_REPORTS
    # end

    private

    def admin_sees_total_reports_number_equal_to(expected_count)
      expect_by_element(expected_count, '#report_counter')
    end

    def admin_sees_harmful_reports_number_equal_to(expected_count)
      expect_by_element(expected_count, '#report_harmful_counter')
    end

    def expect_by_element(expected_count, selector)
      actual_count = find(selector).text.to_i
      expect(actual_count).to eq(expected_count)
    end

    def admin_sees_list_of_reports(reports)
        report_container = find('#report-container')
        child_elements = report_container.all(:xpath, './*').reject { |element| element[:id] == 'notifications' }
        expect(child_elements.size).to eq(expected_count)
    end
  end
end
