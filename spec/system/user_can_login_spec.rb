require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Users Login", type: :system do
  include_context 'user_login'

  context "when user is an admin" do
    let(:admin_status) { true }

    it "does not allow anonymous to access admin dashboard" do
      user_goes_to_admin_dashboard_page
      user_should_redirect_to_login_page
    end

    it "allows admin to login with valid email and password" do
      user_logs_in_with_valid_credential
      user_should_redirect_to_admin_dashboard
    end

    it "does not allow user to login with invalid email and password" do
      user_logs_in_with_invalid_credential
      user_should_notices_email_or_password_is_invalid
    end
  end

  context "when user is a client" do
    let(:admin_status) { false }
  end

  private

  def user_goes_to_admin_dashboard_page
    visit admin_dashboard_index_path
  end

  def user_should_redirect_to_admin_dashboard
    expect(page).to have_current_path(admin_dashboard_index_path)
  end
end
