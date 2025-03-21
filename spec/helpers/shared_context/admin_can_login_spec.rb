require 'rails_helper'

RSpec.shared_context 'admin_can_login' do
  context "admin user exists" do
    before do
      @user = User.create!(email_address: "john@example.com", password: "password", admin: true)
    end

    it "does not allow anonymous to access admin dashboard" do
      user_goes_to_admin_dashboard_page
      user_should_redirect_to_login_page
    end

    it "allows admin to login with valid email and password" do
      user_goes_to_login_page
      user_fill_in_valid_email_and_password
      user_click_log_in_button
      user_should_redirect_to_admin_dashboard
    end

    it "does not allow admin to login with invalid email and password" do
      user_goes_to_login_page
      user_fill_in_invalid_email_and_password
      user_click_log_in_button
      user_should_notices_email_or_password_is_invalid
    end

    private

    def user_goes_to_admin_dashboard_page
      visit admin_dashboard_index_path
    end

    def user_goes_to_login_page
      visit new_session_path
    end

    def user_fill_in_valid_email_and_password
      fill_email_and_password(@user.email_address, @user.password)
    end

    def user_fill_in_invalid_email_and_password
      fill_email_and_password("invalid@email.com", "invalidpassword")
    end

    def fill_email_and_password(email, password)
      fill_in "อีเมล", with: email
      fill_in "รหัสผ่าน", with: password
    end

    def user_click_log_in_button
      click_button "เข้าสู่ระบบ"
    end

    def user_should_redirect_to_admin_dashboard
      expect(page).to have_current_path(admin_dashboard_index_path)
    end

    def user_should_notices_email_or_password_is_invalid
      expect(page).to have_content("อีเมลหรือรหัสผ่านไม่ถูกต้อง")
    end

    def user_should_redirect_to_login_page
      expect(page).to have_current_path(new_session_path)
    end
  end
end
