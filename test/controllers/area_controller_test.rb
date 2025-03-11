require "test_helper"

class AreaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report = reports(:two)
    @user = users(:two)
    @area = areas(:two)

    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get admin_areas_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_area_url
    assert_response :success
  end
end
