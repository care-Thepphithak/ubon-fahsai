require "rails_helper"

describe "Authentication Concern" do
  # Create a dummy controller to include the Authentication module
  controller(ApplicationController) do
    include Authentication

    # Define a dummy action to test the module
    def index
      render plain: "A plain text response for testing Authentication"
    end
  end

  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "#require_authentication" do
    context "when the user is authenticated" do
      before do
        cookies.signed[:session_id] = session.id
        allow(Session).to receive(:find_by).with(id: session.id).and_return(session)
      end

      it "allows access to the action" do
        get :index
        expect(response.body).to eq("A plain text response for testing Authentication")
      end
    end

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  # describe "#start_new_session_for" do
  #   it "creates a new session and sets the session cookie" do
  #     expect {
  #       controller.send(:start_new_session_for, user)
  #     }.to change(Session, :count).by(1)

  #     expect(cookies.signed[:session_id]).to be_present
  #   end
  # end

  # describe "#terminate_session" do
  #   before do
  #     cookies.signed[:session_id] = session.id
  #     Current.session = session
  #   end

  #   it "destroys the current session and deletes the session cookie" do
  #     expect {
  #       controller.send(:terminate_session)
  #     }.to change(Session, :count).by(-1)

  #     expect(cookies.signed[:session_id]).to be_nil
  #   end
  # end

  # describe "#protect_client_access" do
  #   context "when the user is not authenticated" do
  #     it "redirects to the root URL" do
  #       get :index
  #       controller.send(:protect_client_access)
  #       expect(response).to redirect_to(root_url)
  #     end
  #   end

  #   context "when the user is authenticated but not an admin" do
  #     before do
  #       cookies.signed[:session_id] = session.id
  #       allow(Session).to receive(:find_by).with(id: session.id).and_return(session)
  #       allow(session.user).to receive(:admin?).and_return(false)
  #     end

  #     it "allows access to the action" do
  #       controller.send(:protect_client_access)
  #       expect(response).not_to redirect_to(root_url)
  #     end
  #   end
  # end

  # describe "#protect_admin_access" do
  #   context "when the user is authenticated and is an admin" do
  #     before do
  #       cookies.signed[:session_id] = session.id
  #       allow(Session).to receive(:find_by).with(id: session.id).and_return(session)
  #       allow(session.user).to receive(:admin?).and_return(true)
  #     end

  #     it "redirects to the admin dashboard" do
  #       controller.send(:protect_admin_access)
  #       expect(response).to redirect_to(admin_dashboard_index_url)
  #     end
  #   end
  # end
end
