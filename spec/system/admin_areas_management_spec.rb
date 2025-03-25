require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin areas management", type: :system do
  include_context 'user_login'
  fixtures :areas, :users

  context "When user is an admin and already logged in" do
    let(:admin_status) { true }
    let(:areas) { Area.all.order(created_at: :desc) }

    before do
      user_logs_in_with_valid_credential_and_assigned_no_area
      admin_goes_to_areas_management_page
    end

    it "allows admin to see areas management page" do
      admin_should_have_current_path_as_admin_areas
      admin_should_see_a_map
      admin_should_see_a_list_of_areas
    end

    it "allows admin to see area polygon on map when admin clicks on an area" do
      admin_clicks_on_an_area

      admin_should_see_area_polygon_on_map
    end

    it "allows admin to create a new area" do
      admin_start_area_creation
      admin_clicks_on_set_polygon_button
      admin_draws_area_polygon_on_map_with_points 4
      admin_fills_in_area_name "New Area"
      admin_assigns_area_to_user
      admin_clicks_on_save_area_button

      admin_should_have_current_path_as_admin_areas
      admin_should_see_a_new_area 'New Area'
    end


    it "does not allow admin to create new area without filling area name" do
      admin_start_area_creation
      admin_clicks_on_set_polygon_button
      admin_draws_area_polygon_on_map_with_points 3
      admin_assigns_area_to_user
      admin_clicks_on_save_area_button

      admin_sees_message "โปรดระบุชื่อพื้นที่"
    end

    it "does not allow admin to create new area without setting atleast 3 polygon points" do
      admin_start_area_creation
      admin_clicks_on_set_polygon_button
      admin_draws_area_polygon_on_map_with_points 2
      admin_fills_in_area_name "New Area"
      admin_assigns_area_to_user

      admin_sees_message "โปรดระบุพื้นที่ก่อนบันทึก"
    end

    it "does not allow admin to create new area if area name already exist" do
      admin_start_area_creation
      admin_clicks_on_set_polygon_button
      admin_draws_area_polygon_on_map_with_points 3
      admin_fills_in_area_name(areas.first.name)
      admin_assigns_area_to_user
      admin_clicks_on_save_area_button

      admin_sees_message "ชื่อพื้นที่นี้มีอยู่แล้ว"
    end

    it "allows admin to edit an area" do
      admin_start_area_editing
      admin_changes_area_name
      admin_changes_assigned_user
      admin_clicks_on_save_area_button

      admin_should_have_current_path_as_admin_areas
      admin_should_see_a_new_area 'Edited Area'
    end

    it "allows admin to edit an area's polygon" do
      admin_start_area_editing
      admin_click_reset_area_polygon
      admin_clicks_on_set_polygon_button
      admin_draws_area_polygon_on_map_with_points 3
      admin_clicks_on_save_area_button

      admin_should_have_current_path_as_admin_areas
    end

    it "does not allow admin to edit an area without filling area name" do
      admin_start_area_editing
      admin_fills_in_area_name ''
      admin_clicks_on_save_area_button

      admin_sees_message "โปรดระบุชื่อพื้นที่"
    end

    it "does not allow admin to edit an area without setting atleast 3 polygon points" do
      admin_start_area_editing
      admin_click_reset_area_polygon
      admin_clicks_on_set_polygon_button
      admin_draws_area_polygon_on_map_with_points 2

      admin_sees_message "โปรดระบุพื้นที่ก่อนบันทึก"
    end

    it "does not allow admin to edit an area if area name already exist" do
      admin_start_area_editing
      admin_fills_in_area_name(areas.second.name)
      admin_clicks_on_save_area_button

      admin_sees_message "ชื่อพื้นที่นี้มีอยู่แล้ว"
    end

    private

    def admin_start_area_editing
      admin_clicks_on_edit_area_button
      admin_should_have_current_path_as_edit_area
    end

    def admin_start_area_creation
      admin_clicks_on_create_new_area_button
      admin_should_have_current_path_as_new_area
    end

    def admin_sees_message(content)
      expect(page).to have_content(content)
    end

    def admin_goes_to_areas_management_page
      admin_sees_message "Admin"
      visit admin_areas_path
    end

    def admin_should_have_current_path_as_admin_areas
      expect(page).to have_current_path(admin_areas_path)
    end

    def admin_should_see_a_map
      expect(page).to have_selector('[data-testid="areas-management-map"]')
    end

    def admin_should_see_a_list_of_areas
      areas_elements = page.all('[data-testid="area-list-item"]')
      expect(areas_elements.size).to eq(areas.size)

      areas.each_with_index do |area, index|
        expect(areas_elements[index]).to have_content(area.name)
      end
    end

    def admin_should_see_area_polygon_on_map
      expect(page).to have_selector('.leaflet-interactive')
    end

    def admin_should_see_a_new_area(area_name)
      admin_sees_message area_name
    end

    def admin_should_have_current_path_as_edit_area
      expect(page).to have_current_path(edit_admin_area_path(areas.first))
    end

    def admin_clicks_on_an_area
      area = find('[data-testid="area-list-item"]', match: :first)
      expect(area).to be_present
      area.click
    end

    def admin_clicks_on_create_new_area_button
      click_link('เพิ่มพื้นที่')
    end

    def admin_should_have_current_path_as_new_area
      expect(page).to have_current_path(new_admin_area_path)
    end

    def admin_clicks_on_set_polygon_button
      click_button('กำหนดพื้นที่')
    end

    def admin_fills_in_area_name(area_name)
      fill_in('area_name', with: area_name)
    end

    def admin_assigns_area_to_user
      first_user = find('label', text: users(:client_one).email_address)
      expect(first_user).to be_present

      first_user.click
    end

    def admin_clicks_on_save_area_button
      click_button('บันทึกพื้นที่')
    end

    def admin_clicks_on_edit_area_button
      area = find('[data-testid="area-list-item"]', match: :first)
      expect(area).to be_present
      area.find('a').click
    end

    def admin_changes_area_name
      fill_in('area_name', with: 'Edited Area')
    end

    def admin_changes_assigned_user
      second_user = find('label', text: users(:client_two).email_address)
      expect(second_user).to be_present

      second_user.click
    end

    def admin_draws_area_polygon_on_map_with_points(number_of_points)
      map = find('#area-management-map')
      expect(map).to be_present

      coordinates = Array.new(number_of_points) do
        { x: rand(20..200), y: rand(20..200) }
      end

      coordinates.each do |coord|
        map.click(x: coord[:x], y: coord[:y])
        sleep 0.5
      end

      expect(page).to have_selector('.leaflet-interactive', wait: 5)
    end

    def admin_click_reset_area_polygon
      click_button('รีเซ็ตพื้นที่')
    end
  end
end
