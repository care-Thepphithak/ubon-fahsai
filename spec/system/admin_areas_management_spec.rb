require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'
  fixtures :areas, :users, :user_areas

  context "When user is an admin and already logged in" do
    let(:admin_status) { true }
    let(:areas) { Area.all }

    before do
      user_logs_in_with_valid_credential
    end

    it "allows admin to see areas management page" do
      admin_goes_to_areas_management_page
      admin_should_have_current_path_as_admin_areas
      admin_should_see_a_map
      admin_should_see_a_list_of_areas
    end

    it "can show area polygon on map when admin clicks on an area" do
      admin_clicks_on_an_area
      admin_should_see_area_polygon_on_map
    end

    it "can create a new area" do
      admin_clicks_on_create_new_area_button
      admin_should_have_current_path_as_new_area
      admin_selects_area_on_map
      admin_fills_in_area_name
      admin_assigns_area_to_user
      admin_clicks_on_save_area_button
    end

    it "can edit an area" do
      admin_clicks_on_edit_area_button
      admin_should_have_current_path_as_edit_area
      admin_changes_area_name
      admin_changes_assigned_user
      admin_clicks_on_save_area_button
    end

    it "can edit an area's polygon" do
      admin_clicks_on_edit_area_button
      admin_should_have_current_path_as_edit_area
      admin_clicks_on_edit_polygon_button
      admin_changes_area_polygon
      admin_clicks_on_save_area_button
    end

    private

    def admin_goes_to_areas_management_page
      expect(page).to have_content("Admin")
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
  end
end
