require "test_helper"

class AreaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get area_index_url
    assert_response :success
  end

  test "should get new" do
    get area_new_url
    assert_response :success
  end
end
