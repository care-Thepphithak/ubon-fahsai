require 'rails_helper'

describe User do
  it "is valid with a email and password" do
    user = User.new(email_address: "john@example.com", password_digest: "password")
    expect(user).to be_valid
  end
end
