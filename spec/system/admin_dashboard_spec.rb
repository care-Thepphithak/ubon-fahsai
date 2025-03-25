require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'
  fixtures :reports

  context "When user is an admin and already logged in" do
    let(:admin_status) { true }
    let(:all_reports) { Report.all.order(created_at: :desc) }
    let(:today_reports) { all_reports.today }
    let(:total_harmful_reports_today) { today_reports.harmful.count }
    let(:today_reports_oldest_order) { today_reports.reorder(created_at: :asc) }
    let(:tags) { Report::TAGS }

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

    it "can filter and show the oldest reports first" do
      admin_selects_filter_oldest_reports
      admin_sees_list_of_reports today_reports_oldest_order
    end

    it "can filter and show reports reference by tag" do
      tags.each do |tag|
        admin_selects_filter_by_tag tag
        tag_filtered_reports = today_reports.where("tags @> ?", [ tag ].to_json)
        admin_sees_list_of_reports tag_filtered_reports
      end
    end

    it "can view report information" do
      admin_select_first_report
      admin_select_highlighted_report_pin_to_open_infomation_modal
      admin_sees_report_location_in_modal
      admin_sees_report_severity_level_in_modal
      admin_sees_report_description_in_modal
    end

    private

    def admin_selects_filter_oldest_reports
      find('#dateFilter').find('option', text: 'เก่าสุด').click
    end

    def admin_selects_filter_all_reports
      find('#filterGroup').find('option', text: 'การรายงานทั้งหมด').click
    end

    def admin_selects_filter_by_tag(tag)
      find('#tag-sort').find('option', text: tag).click
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

    def admin_select_first_report
      sleep 2
      find('[data-testid="location-name"]', match: :first).click
    end

    def admin_select_highlighted_report_pin_to_open_infomation_modal
      expect(page).to have_selector('.leaflet-marker-icon', visible: true)
      execute_script('document.querySelector(".leaflet-marker-icon").scrollIntoView()')
      find('.leaflet-marker-icon', match: :first).click

      expect(page).to have_selector('[data-testid="modal-location-name"]', visible: true)
    end

    def admin_sees_report_location_in_modal
       location = find('[data-testid="modal-location-name"]').text
       expect(location).to eq(today_reports.first.location_name)
    end

    def admin_sees_report_severity_level_in_modal
      severity = find('[data-testid="modal-severity-level"]').text
      expect(severity).to eq(today_reports.first.severity_level)
    end

    def  admin_sees_report_description_in_modal
      description = find('[data-testid="modal-description"]').text
      expect(description).to eq(today_reports.first.description)
    end

    def admin_sees_list_of_reports(reports)
      reports_count = reports.count

      if reports_count.zero?
        expect(page).to have_selector('#report-container > *', count: 0)
        return
      end

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
  end
end
