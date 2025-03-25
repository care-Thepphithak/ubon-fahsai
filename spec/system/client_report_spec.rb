require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Client Report", type: :system do
  include_context 'user_login'
  fixtures :reports

  context "When user is a client and already_logged_in and there are reports today" do
    let(:admin_status) { false }
    let(:all_reports) { Report.all.order(created_at: :desc) }
    let(:today_reports) { all_reports.today }
    let(:tags) { Report::TAGS }

    # location of Ubon Ratchathani
    LATITUDE_INSIDE_AREA = 15.2284
    LONGITUDE_INSIDE_AREA = 104.8561

    LATITUDE_OUTSIDE_AREA = 15.2295
    LONGITUDE_OUTSIDE_AREA = 104.8560

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

    it "displays the current location" do
      assign_current_location LATITUDE_INSIDE_AREA, LONGITUDE_INSIDE_AREA
      client_sees_current_location
    end

    it "displays the number of reports today" do
      client_sees_total_reports_number_equal_to today_reports.count
    end

    it "allows client to report inside their area" do
      client_click_report_button
      client_sees_heading_in_report_page
      client_click_choose_image_button
      client_choose_image
      client_sees_preview_selected_image
      client_click_next_button
      client_click_tags
      client_write_description "ไฟไหม้ในที่รกร้าง"
      client_input_severity_level
      client_click_next_to_map_button
      assign_current_location LATITUDE_INSIDE_AREA, LONGITUDE_INSIDE_AREA
      sleep 2
      client_click_send_report
      client_click_accept_send_report
      client_sees_success_message
      client_sees_the_nearest_distance_report 0.00
    end

    it "doesn't allow client to report outside the area" do
      client_click_report_button
      client_sees_heading_in_report_page
      client_click_choose_image_button
      client_choose_image
      client_sees_preview_selected_image
      client_click_next_button
      client_click_tags
      client_write_description "ไฟไหม้ในที่รกร้าง"
      client_input_severity_level
      client_click_next_to_map_button
      assign_current_location LATITUDE_OUTSIDE_AREA, LONGITUDE_OUTSIDE_AREA
      client_cannot_click_send_report
      sleep 10
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

    def assign_current_location(latitude, longitude)
      page.execute_script <<-JS
      window.navigator.geolocation.getCurrentPosition = function(success) {
        success({ coords: {latitude: #{latitude}, longitude: #{longitude} } });
      };
      JS
    end

    def client_sees_current_location
      expect(page).to have_content("ถนนศรีณรงค์ ตำบลในเมือง เทศบาลนครอุบลราชธานี ปทุม จังหวัดอุบลราชธานี")
    end

    def client_click(selector)
      report_button = find(selector)
      expect(report_button).to be_visible
      report_button.click
    end

    def client_click_next_to_map_button
      next_to_map_button = '[data-action="click->report#next"]'
      client_click next_to_map_button
    end

    def client_click_send_report
      send_report_button = '[data-action="click->bottom-sheet#open"]'
      client_click send_report_button
    end

    def client_click_accept_send_report
      accept_send_report_button = '[data-action="click->bottom-sheet#submit"]'
      client_click accept_send_report_button
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
      attach_file("report[images][]", [
        Rails.root.join('spec/fixtures/files/fire.jpg'),
        Rails.root.join('spec/fixtures/files/test.jpg')
      ], make_visible: true)
    end

    def client_sees_preview_selected_image
      expect(page).to have_css("img[src^='data:image/jpeg;base64,'][class='min-w-64 h-72 w-64 object-cover rounded-lg shadow-md']")
    end

    def client_click_next_button
      next_button = "#upload-step-next"
      client_click next_button
    end

    def client_click_tags
      tags.each do |tag|
        tag_selected = '[data-tag="' + tag + '"]'
        client_click tag_selected
      end
    end

    def client_write_description(description)
      fill_in "report[description]", with: description
    end

    def client_input_severity_level
      slider = find('#severity-range')
      slider.set(75)
      expect(find('[data-testid="severity-level-label"]').text).to eq("รุนแรงมาก")
    end

    def client_sees_success_message
      expect(page).to have_content("รายงานสำเร็จ")
    end

    def client_sees_the_nearest_distance_report(distance)
      expect(page).to have_content(distance)
    end

    def client_cannot_click_send_report
      expect(page).to have_content("ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ")
      submit_button = find('#submit')
      expect(submit_button).to be_disabled
    end
  end
end
