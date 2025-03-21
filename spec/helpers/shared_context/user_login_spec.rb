RSpec.shared_context 'user_login' do
  before do
    @user = User.create!(email_address: "john@example.com", password: "password", admin: admin_status)
  end

  def user_goes_to_login_page
    visit new_session_path
  end

  def user_fills_in_credentials
    fill_in "อีเมล", with: @user.email_address
    fill_in "รหัสผ่าน", with: @user.password
  end

  def user_clicks_login_button
    click_button "เข้าสู่ระบบ"
  end

  def user_logs_in
    user_goes_to_login_page
    user_fills_in_credentials
    user_clicks_login_button
  end
end
