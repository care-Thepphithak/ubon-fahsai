require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  fixtures :reports, :users, :areas

  describe "GET #index" do
    let(:user) { users(:client_one) }

    before do
      allow(Current).to receive(:user).and_return(user)
    end

    it "returns a success response" do
    end
  end
end
