require 'rails_helper'

describe User do
  describe 'email normalization' do
    let(:user) { create(:user, email_address: " JOHN@EXAMPLE.COM") }

    it "downcases and strips email_address" do
      expect(user.email_address).to eq("john@example.com")
    end
  end

  describe 'scope admin' do
    let(:admin_user) { create(:user, :admin) }
    let(:non_admin_user) { create(:user) }

    context "when user is an admin" do
      it 'returns true' do
        expect(admin_user.admin?).to eq(true)
      end
    end

    context "when user is not an admin" do
      it 'returns false' do
        expect(non_admin_user.admin?).to eq(false)
      end
    end
  end
end
