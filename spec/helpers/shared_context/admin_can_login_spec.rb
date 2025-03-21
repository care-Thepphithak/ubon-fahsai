require 'rails_helper'

RSpec.shared_context 'admin_can_login' do
  context "admin user exists" do
    before {
    User.create!(email_address: "john@example.com", password: "password", admin: true)
     }
  end

  it "allows users to log in" do
    user = User.create!(email_address: "john@example.com", password: "password")

    visit "/session/new"
    fill_in "อีเมล", with: user.email_address
    fill_in "รหัสผ่าน", with: user.password
    click_button "เข้าสู่ระบบ"

    expect(page).to have_content("อุบลฟ้าใส สวัสดี")
  end

  it "allows admin to login with valid email and password" do
    user_goes_to_login_page
    user_fill_in_valid_email_and_password
    user_click_log_in_button
  end
  it "does not allow admin to login with invalid email and password" do
  end
  it "does not allow anonymous to access this website" do
  end

  def user_goes_to_login_page
    visit "/session/new"
  end
  def user_fill_in_valid_email_and_password
    fill_in "อีเมล", with: "john@example.com"
    fill_in "รหัสผ่าน", with: "password"
  end
  def user_click_log_in_button
    click_button "เข้าสู่ระบบ"
  end
end
