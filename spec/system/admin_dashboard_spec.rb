require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'
  fixtures :reports

  context "When user is an admin and already_logged_in and there are reports today" do
    let(:admin_status) { true }
    let(:all_reports) { Report.all.order(created_at: :desc) }
    let(:today_reports) { all_reports.today }
    let(:total_harmful_reports_today) { today_reports.harmful.count }

    before do
      user_logs_in_with_valid_credential
    end

    it "displays the admin dashboard page" do
      expect(page).to have_content("Admin")
    end

    it "displays the number of reports today" do
      admin_sees_total_reports_number_equal_to today_reports.count
    end

    it "displays the number of harmful reports" do
      admin_sees_harmful_reports_number_equal_to total_harmful_reports_today
    end

    it "displays list of today's reports" do
      admin_sees_list_of_reports today_reports
    end

    it "displays list of all reports" do
      admin_selects_filter_all_reports
      admin_sees_list_of_reports all_reports
    end

    it "can filter oldest reports" do
      admin_selects_filter_oldest_reports
      admin_sees_list_of_reports_order_by Report.all.today.order(created_at: :asc)
    end

    private

    def admin_selects_filter_oldest_reports
      find('#dateFilter').find('option', text: 'เก่าสุด').click
    end

    def admin_selects_filter_all_reports
      find('#filterGroup').find('option', text: 'การรายงานทั้งหมด').click
    end

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
      reports_count = reports.count
      report_container = find('#report-container')

      expect(report_container).to have_selector(:xpath, './*', count: reports_count)

      child_elements = report_container.all(:xpath, './*').reject { |element| element[:id] == 'notifications' }

      expect(child_elements.count).to eq(reports_count)

      reports.each_with_index do |report, index|
        location_name_text = child_elements[index].find('[data-testid="location-name"]').text
        severity_level_text = child_elements[index].find('[data-testid="severity-level"]').text
        tags = JSON.parse(report.tags) rescue []

        expect(location_name_text).to eq(report.location_name)
        expect(severity_level_text).to eq(report.severity_level)

        if tags.any?
          report_tags = child_elements[index].all('[data-testid="tags"]').map(&:text)
          expect(report_tags).to match_array(tags)
        end
      end
    end

    def admin_sees_list_of_reports_order_by(reports)
      sleep 1
      reports_count = reports.count
      report_container = find('#report-container')

      child_elements = report_container.all(:xpath, './*').reject { |element| element[:id] == 'notifications' }

      expect(child_elements.count).to eq(reports_count)
      reports.each_with_index do |report, index|
        location_name_text = child_elements[index].find('[data-testid="location-name"]').text
        severity_level_text = child_elements[index].find('[data-testid="severity-level"]').text
        tags = JSON.parse(report.tags) rescue []

        expect(location_name_text).to eq(report.location_name)
        expect(severity_level_text).to eq(report.severity_level)

        if tags.any?
          report_tags = child_elements[index].all('[data-testid="tags"]').map(&:text)
          expect(report_tags).to match_array(tags)
        end
      end
    end
  end
end
