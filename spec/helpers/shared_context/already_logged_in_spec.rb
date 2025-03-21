require 'rails_helper'

RSpec.shared_context "already_logged_in" do
  # TODO: Do something that logs in the user so that it ready to be used in the test
  before do
    @user = User.create!(email_address: "user@example.com", password: "password", admin: admin_status)
  end
end
