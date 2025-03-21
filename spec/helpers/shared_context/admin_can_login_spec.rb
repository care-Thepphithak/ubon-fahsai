require 'rails_helper'

RSpec.shared_context 'admin_can_login' do
  context "admin user exists" do
    before do
      @user = User.create!(email_address: "john@example.com", password: "password", admin: true)
    end
  end
end
