require 'rails_helper'

RSpec.shared_context 'admin_can_login' do
  context "admin user exists" do
    before do
      @user = User.create!(email_address: "john@example.com", password: "password", admin: true)
    end

    it "allows admin to login with valid email and password" do
      user_goes_to_login_page
      user_fill_in_valid_email_and_password
      user_click_log_in_button
      user_should_redirect_to_admin_dashboard
    end

    it "does not allow admin to login with invalid email and password" do
      user_goes_to_login_page
      fill_in "อีเมล", with: "invalid.email@example.com"
      fill_in "รหัสผ่าน", with: "invalidpassword"
      user_click_log_in_button
      expect(page).to have_content("อีเมลหรือรหัสผ่านไม่ถูกต้อง")
    end

    it "does not allow anonymous to access this website" do
    end

    def user_goes_to_login_page
      visit new_session_path
    end

    def user_fill_in_valid_email_and_password
      fill_in "อีเมล", with: @user.email_address
      fill_in "รหัสผ่าน", with: @user.password
    end

    def user_click_log_in_button
      click_button "เข้าสู่ระบบ"
    end

    def user_should_redirect_to_admin_dashboard
      expect(page).to have_current_path(admin_dashboard_index_path)
    end
  end
end
