require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Client Report", type: :system do
  include_context 'user_login'
  fixtures :reports

  let(:admin_status) { false }
  let(:all_reports) { Report.all.order(created_at: :desc) }
  let(:today_reports) { all_reports.today }
  let(:first_report) { all_reports.first }

  shared_examples "client report home page" do
    it "displays the client report home page" do
      client_sees_greeting_in_report_home_page
    end

    it "displays the current date and time" do
      client_sees_current_date_and_time_correctly
    end
  end

  context "When a user is a client and has no assigned areas" do
    before do
      user_logs_in_with_valid_credential_and_assigned_no_area
    end

    include_examples "client report home page"

    it "displays the current location" do
      set_current_location(LATITUDE_INSIDE_AREA, LONGITUDE_INSIDE_AREA, CURRENT_LOCATION_NAME)
      client_sees_current_location
    end

    it "displays the number of reports today" do
      client_sees_total_reports_number_equal_to today_reports.count
    end

    it "no displays report button and not allow to click the report button" do
      client_cannot_see '[data-testid="client-report-button"]'
    end
  end

  context "When a user is a client and has assigned areas" do
    let(:tags) { Report::TAGS }

    CURRENT_LOCATION_NAME = "ถนนศรีณรงค์ ตำบลในเมือง เทศบาลนครอุบลราชธานี ปทุม จังหวัดอุบลราชธานี"
    LATITUDE_INSIDE_AREA = 15.2284
    LONGITUDE_INSIDE_AREA = 104.8561

    LATITUDE_OUTSIDE_AREA = 15.2295
    LONGITUDE_OUTSIDE_AREA = 104.8560

    before do
      user_logs_in_with_valid_credential_and_assigned_area
    end

    include_examples "client report home page"

    it "displays the current location" do
      set_current_location(LATITUDE_INSIDE_AREA, LONGITUDE_INSIDE_AREA, CURRENT_LOCATION_NAME)
      client_sees_current_location
    end

    it "displays the number of reports today" do
      client_sees_total_reports_number_equal_to today_reports.count
    end

    it "allows client to report inside their area" do
      client_reports_fire_in_area(LATITUDE_INSIDE_AREA, LONGITUDE_INSIDE_AREA, CURRENT_LOCATION_NAME)
      client_sees_success_message
      client_sees_the_nearest_distance_report 0.00
      client_sees_the_latest_report
    end

    it "doesn't allow client to report outside the area" do
      client_reports_fire_outside_area(LATITUDE_OUTSIDE_AREA, LONGITUDE_OUTSIDE_AREA)
      client_sees_outside_area_warning_message
      client_sees_submit_button_disabled
    end
  end

  private

  def set_current_location(latitude, longitude, location_name)
    assign_current_location(latitude, longitude)
    stub_location_name(location_name)
  end

  def client_reports_fire_in_area(latitude, longitude, location_name)
    client_click_report_button
    client_sees_heading_in_report_page
    client_click_choose_image_button
    client_choose_image
    client_sees_preview_selected_image
    client_click_upload_step_next_button
    client_click_tags
    client_write_description "ไฟไหม้ในที่รกร้าง"
    client_input_severity_level
    client_click_detail_step_next_button
    set_current_location(latitude, longitude, location_name)
    sleep 2
    client_click_send_report
    client_click_accept_send_report
  end

  def client_reports_fire_outside_area(latitude, longitude)
    client_click_report_button
    client_sees_heading_in_report_page
    client_click_choose_image_button
    client_choose_image
    client_sees_preview_selected_image
    client_click_upload_step_next_button
    client_click_tags
    client_write_description "ไฟไหม้ในที่รกร้าง"
    client_input_severity_level
    client_click_detail_step_next_button
    assign_current_location(latitude, longitude)
  end

  def client_cannot_see(selector)
    expect(page).to have_no_selector(selector, visible: true)
  end

  def client_sees_the_latest_report
    expect(first_report.severity_level).to eq("รุนแรงมาก")
    expect(first_report.description).to eq("ไฟไหม้ในที่รกร้าง")
    expect(first_report.created_at).to be_within(1.minute).of(Time.current)
  end

  def client_click(selector)
    button = find(selector)
    expect(button).to be_visible
    button.click
  end

  def client_click_upload_step_next_button
    client_click '[data-testid="upload-step-next-button"]'
  end

  def client_click_detail_step_next_button
    client_click '[data-testid="detail-step-next-button"]'
  end

  def client_click_send_report
    client_click '[data-testid="send-report-button"]'
  end

  def client_click_accept_send_report
    client_click '[data-testid="submit-report-button"]'
  end

  def client_click_report_button
    client_click '[data-testid="client-report-button"]'
  end

  def client_sees_heading_in_report_page
    expect(page).to have_content("รายงานไฟไหม้")
  end

  def client_click_choose_image_button
    client_click "label[for='report_images']"
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

  def client_click_tags
    tags.each do |tag|
      client_click "[data-tag='#{tag}']"
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

  def client_sees_outside_area_warning_message
    expect(page).to have_content("ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ")
  end

  def client_sees_submit_button_disabled
    expect(find('#submit')).to be_disabled
  end

  def client_sees_greeting_in_report_home_page
    expect(page).to have_content("อุบลฟ้าใส สวัสดี")
  end

  def client_sees_current_date_and_time_correctly
    expect(page).to have_content(I18n.l(Time.current, format: :full, locale: :th))
  end

  def assign_current_location(latitude, longitude)
    page.execute_script <<-JS
    window.navigator.geolocation.getCurrentPosition = function(success) {
      success({ coords: {latitude: #{latitude}, longitude: #{longitude} } });
    };
    JS
  end

  def stub_location_name(location_name)
    page.execute_script <<-JS
    window.fetch = function() {
      return Promise.resolve({
        json: function() {
          return { display_name: "#{location_name}" };
        }
      });
    };
    JS
  end

  def client_sees_current_location
    expect(page).to have_content(CURRENT_LOCATION_NAME)
  end

  def client_sees_total_reports_number_equal_to(expected_count)
    expect_by_element(expected_count, '[data-testid="client-report-counter"]')
  end

  def expect_by_element(expected_count, selector)
    actual_count = find(selector).text.to_i
    expect(actual_count).to eq(expected_count)
  end
end
