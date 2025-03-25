require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Client Report", type: :system do
  include_context 'user_login'

  context "When user is a client and already_logged_in and there are reports today" do
    let(:admin_status) { false }

    before do
      user_logs_in_with_valid_credential

      stub_request(:get, /nominatim.openstreetmap.org/).to_return(
      body: { display_name: "Bangkok, Thailand" }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    end

    it "displays the report page" do
      client_sees_greeting_in_report_page
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
    end

    def client_sees_greeting_in_report_page
      expect(page).to have_content("อุบลฟ้าใส สวัสดี")
    end

    def client_sees_current_date_and_time_correctly
      expect(page).to have_content(I18n.l(Time.current, format: :full, locale: :th))
    end


    # def client_sees_current_location
    #   expect(page).to have_content("ถนนวิทยวัฒนา บ้านศูนย์แพทย์ 1 เทศบาลนครขอนแก่น ศิลา จังหวัดขอนแก่น")
    # end
  end
end
