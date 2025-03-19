require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a email and password" do
    user = User.new(email_address: "john@example.com", password_digest: "password")
    expect(user).to be_valid
  end
end
