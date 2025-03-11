require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report = reports(:one)
    @user = users(:one)
    @area = areas(:one)

    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get reports_url
    assert_response :success
  end

  test "should create report" do
    assert_difference("Report.count") do
      post reports_url, params: {
        report: {
          lat: @report.lat,
          long: @report.long,
          location_name: "Test Location",
          description: "Test Description",
          severity_level: "ลุกลาม",
          area_ids: @area.id.to_s,
          tags: [ "ไฟป่า", "เผาไร่อ้อย" ].to_json,
          images: { "0" => fixture_file_upload("fire.jpg", "image/jpg") }
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Test Location", Report.last.location_name
  end

  test "should fail to create report with invalid params" do
    post reports_url, params: {
      report: {
        lat: nil,
        long: nil,
        area_ids: "",
        location_name: "",
        description: "",
        severity_level: "",
        tags: [].to_json
      }
    }

    assert_response :not_acceptable
  end
end
