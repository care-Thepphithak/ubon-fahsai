require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'

  context "When user is an admin and already_logged_in" do
    let(:admin_status) { true }

    before do
      user_logs_in_with_valid_credential
    end

    it "displays the admin dashboard page" do
      expect(page).to have_content("Admin")
    end
  end
end
