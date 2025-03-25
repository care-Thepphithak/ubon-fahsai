require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Client Report", type: :system do
  include_context 'user_login'

  context "When user is a client and already_logged_in and there are reports today" do
    let(:admin_status) { false }

    before do
      user_logs_in_with_valid_credential
    end

    it "displays the report page" do
      client_sees_greeting_in_report_page
    end

    it "displays the current location" do
      sleep 3
      client_sees_greeting_in_report_page
    end

    def client_sees_greeting_in_report_page
      expect(page).to have_content("อุบลฟ้าใส สวัสดี")
    end

    def client_sees_current_location
      expect(page).to have_content("ถนนวิทยวัฒนา บ้านศูนย์แพทย์ 1 เทศบาลนครขอนแก่น ศิลา จังหวัดขอนแก่น")
    end
  end
end
