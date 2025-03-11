require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report = reports(:one)
    @user = users(:one)
    @area = areas(:one)

    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get root_url
    assert_response :success
  end
end
