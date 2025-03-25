require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'
  fixtures :areas, :users, :user_areas

  context "When user is an admin and already_logged_in and there are reports today" do
    let(:admin_status) { true }

    before do
      user_logs_in_with_valid_credential
    end
  end
end
