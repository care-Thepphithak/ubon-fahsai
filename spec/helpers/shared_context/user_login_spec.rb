RSpec.shared_context 'user_login' do
  before do
    @user = User.create!(email_address: "john@example.com", password: "password", admin: admin_status)

    if admin_status == false
      @area = Area.create!(
        name: "Test Area 1",
        created_at: "2021-06-02 00:00:00",
        updated_at: "2021-06-02 00:00:00",
        coordinates: [
          [
            15.228601696117504,
            104.8553895032195
          ],
          [
            15.22793398472127,
            104.8554216993608
          ],
          [
            15.227959865047405,
            104.85613538049367
          ],
          [
            15.228011625690133,
            104.85670954501411
          ],
          [
            15.228591344019005,
            104.85651100214258
          ]
        ]
      )
      UserArea.create(user: @user, area: @area)
    end
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

  def user_clicks_login_button
    click_button "เข้าสู่ระบบ"
  end

  def user_should_notices_email_or_password_is_invalid
    expect(page).to have_content("อีเมลหรือรหัสผ่านไม่ถูกต้อง")
  end

  def user_should_redirect_to_login_page
    expect(page).to have_current_path(new_session_path)
  end

  def user_logs_in_with_valid_credential
    user_goes_to_login_page
    user_fill_in_valid_email_and_password
    user_clicks_login_button
  end

  def user_logs_in_with_invalid_credential
    user_goes_to_login_page
    user_fill_in_invalid_email_and_password
    user_clicks_login_button
  end
end
