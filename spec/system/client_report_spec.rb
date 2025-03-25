require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Client Report", type: :system do
  include_context 'user_login'
  fixtures :reports

  context "When user is a client and already_logged_in and there are reports today" do
    let(:admin_status) { false }
    let(:all_reports) { Report.all.order(created_at: :desc) }
    let(:today_reports) { all_reports.today }

    before do
      user_logs_in_with_valid_credential

      stub_request(:get, /nominatim.openstreetmap.org/).to_return(
      body: { display_name: "Bangkok, Thailand" }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    end

    it "displays the client report home page" do
      client_sees_greeting_in_report_home_page
    end

    it "displays the current date and time" do
      client_sees_current_date_and_time_correctly
    end

    # it "displays the current location" do
    #   sleep 3

    #   page.execute_script <<-JS
    #   window.navigator.geolocation.getCurrentPosition = function(success) {
    #     success({ coords: { latitude: 13.7563, longitude: 100.5018 } }); // Bangkok
    #   };
    # JS

    # sleep 5

    # # Wait for the page to update (optional sleep if needed)
    # expect(page).to have_content("กรุงเทพ")
    # end

    it "displays the number of reports today" do
      client_sees_total_reports_number_equal_to today_reports.count
    end

    it "display the report list when client report" do
      client_click_report_button
      client_sees_heading_in_report_page
      client_click_choose_image_button
    end

    private

    def client_sees_greeting_in_report_home_page
      expect(page).to have_content("อุบลฟ้าใส สวัสดี")
    end

    def client_sees_current_date_and_time_correctly
      expect(page).to have_content(I18n.l(Time.current, format: :full, locale: :th))
    end

    def client_sees_total_reports_number_equal_to(expected_count)
      expect_by_element(expected_count, '[data-testid="client-report-counter"]')
    end

    def expect_by_element(expected_count, selector)
      actual_count = find(selector).text.to_i
      expect(actual_count).to eq(expected_count)
    end

    # def client_sees_current_location
    #   expect(page).to have_content("ถนนวิทยวัฒนา บ้านศูนย์แพทย์ 1 เทศบาลนครขอนแก่น ศิลา จังหวัดขอนแก่น")
    # end

    def client_click(selector)
      report_button = find(selector)
      expect(report_button).to be_visible
      report_button.click
    end

    def client_click_report_button
      report_button = '[data-testid="client-report-button"]'
      client_click report_button
    end

    def client_sees_heading_in_report_page
      expect(page).to have_content("รายงานไฟไหม้")
    end

    def client_click_choose_image_button
      choose_image_button = "label[for='report_images']"
      client_click choose_image_button
    end

    def client_choose_image
    end

    def client_sees_preview_selected_image
    end
  end
end
