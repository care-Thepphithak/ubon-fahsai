require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'
  fixtures :areas, :users, :user_areas

  context "When user is an admin and already logged in" do
    let(:admin_status) { true }

    before do
      user_logs_in_with_valid_credential
    end

    it "allows admin to see areas management page" do
      # admin_goes_to_areas_management_page
      # admin_should_have_current_path_as_admin_areas
      # admin_should_see_a_map
      # admin_should_see_a_list_of_areas
    end

    private

    def admin_goes_to_areas_management_page
      visit admin_areas_path
    end

    def admin_should_have_current_path_as_admin_areas
      expect(page).to have_current_path(admin_areas_path)
    end
  end
end
