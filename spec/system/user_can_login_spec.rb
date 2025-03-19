require 'rails_helper'

RSpec.describe "User Login", type: :system do
  it "allows users to log in" do
    user = User.create!(email_address: "john@example.com", password: "password")

    visit "/session/new"
    fill_in "อีเมล", with: user.email_address
    fill_in "รหัสผ่าน", with: user.password
    click_button "เข้าสู่ระบบ"

    expect(page).to have_content("อุบลฟ้าใส สวัสดี")
  end
end
