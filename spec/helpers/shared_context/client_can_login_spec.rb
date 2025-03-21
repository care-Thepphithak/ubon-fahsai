require 'rails_helper'

RSpec.shared_context 'client_can_login' do
  context "client user exists" do
    before do
      @user = User.create!(email_address: "client@example.com", password: "password")
    end
  end
end
