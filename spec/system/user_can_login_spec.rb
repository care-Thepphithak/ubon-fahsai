require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

describe "Users Login" do
  include_context 'user_login'

  context "when user is an admin" do
    let(:admin_status) { true }

    it "does not allow anonymous to access admin dashboard" do
      user_goes_to_admin_dashboard_page
      user_should_redirect_to_login_page
    end

    it "allows admin to login with valid email and password" do
      user_logs_in_with_valid_credential_and_assigned_no_area
      user_should_redirect_to admin_dashboard_index_path
    end

    it "does not allow user to login with invalid email and password" do
      user_logs_in_with_invalid_credential
      user_should_notices_email_or_password_is_invalid
    end
  end

  context "when user is a client" do
    let(:admin_status) { false }

    it "does not allow anonymous to access client page" do
      user_goes_to_client_report_page
      user_should_redirect_to_login_page
    end

    it "allows client to login with valid email and password" do
      user_logs_in_with_valid_credential_and_assigned_no_area
      user_should_redirect_to root_path
    end

    it "does not allow client to login with invalid email and password" do
      user_logs_in_with_invalid_credential
      user_should_notices_email_or_password_is_invalid
    end
  end

  private

  def user_goes_to_admin_dashboard_page
    visit admin_dashboard_index_path
  end

  def user_goes_to_client_report_page
    visit root_path
  end

  def user_should_redirect_to(path)
    expect(page).to have_current_path(path)
  end
end
