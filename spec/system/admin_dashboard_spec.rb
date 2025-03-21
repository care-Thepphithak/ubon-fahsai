require 'rails_helper'
require_relative '../helpers/shared_context/user_login_spec'

RSpec.describe "Admin Dashboard", type: :system do
  include_context 'user_login'

  before do
    let(:admin_status) { true }
    user_logs_in_with_valid_credential
  end

  it "displays the admin dashboard page" do
  end
end
