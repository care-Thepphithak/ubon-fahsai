require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report = reports(:two)
    @user = users(:two)
    @area = areas(:two)

    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get admin_dashboard_index_url
    assert_response :success
  end
end
