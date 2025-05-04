require 'rails_helper'

RSpec.describe PwaController, type: :controller do
  before do
    # Skip authentication for all tests
    allow(controller).to receive(:require_authentication).and_return(true)
  end

  describe "GET #service_worker" do
    it "returns a successful response with javascript content type" do
      allow(controller).to receive(:render).and_return("service worker content")

      # Call the action
      get :service_worker, format: :js

      expect(response).to be_successful
      expect(controller).to have_received(:render).with(:service_worker, hash_including(content_type: "application/javascript"))
    end
  end

  describe "GET #manifest" do
    it "returns a successful response with manifest content type" do
      allow(controller).to receive(:render).and_return("manifest content")

      # Call the action - use JSON format to match the expected response
      get :manifest, format: :json

      expect(response).to be_successful
      expect(controller).to have_received(:render).with(:manifest, hash_including(content_type: "application/manifest+json"))
    end
  end
end
