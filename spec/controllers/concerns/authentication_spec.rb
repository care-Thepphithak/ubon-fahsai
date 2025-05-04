require "rails_helper"
require "helpers/shared_context/authentication_spec"

describe Authentication do
  controller(ActionController::Base) do
    include Authentication
  end

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:session) { create(:session, user: user, ip_address: "127.0.0.1", user_agent: "TestAgent") }
  let(:admin_session) { create(:session, user: admin_user, ip_address: "127.0.0.1", user_agent: "TestAgent") }

  describe "request_authentication method" do
    it "stores return_to_after_authenticating in session and redirects to new_session_path" do
      allow(controller.request).to receive(:url).and_return("http://test.host/protected")

      expect(controller).to receive(:redirect_to).with(controller.new_session_path)
      controller.send(:request_authentication)

      expect(controller.session[:return_to_after_authenticating]).to eq("http://test.host/protected")
    end
  end

  describe "start_new_session_for method" do
    it "creates a new session for the user and sets cookies" do
      allow(controller.request).to receive(:user_agent).and_return("TestAgent")
      allow(controller.request).to receive(:remote_ip).and_return("127.0.0.1")

      signed_cookies = {}
      allow(controller.send(:cookies)).to receive(:signed).and_return(double(permanent: signed_cookies))

      expect(user.sessions).to receive(:create!).with(user_agent: "TestAgent", ip_address: "127.0.0.1").and_return(session)
      expect(Current).to receive(:session=).with(session)
      expect(signed_cookies).to receive(:[]=).with(:session_id, { value: session.id, httponly: true, same_site: :lax })

      result = controller.send(:start_new_session_for, user)
      expect(result).to eq(session)
    end
  end

  describe "terminate_session method" do
    it "destroys the current session and deletes the session_id cookie" do
      allow(Current).to receive(:session).and_return(session)
      allow(controller.send(:cookies)).to receive(:delete).with(:session_id)

      expect(Current.session).to receive(:destroy)
      controller.send(:terminate_session)
    end
  end

  describe "after_authentication_url method" do
    it "deletes return_to_after_authenticating from session and also returns the deleted url" do
      controller.session[:return_to_after_authenticating] = "/some_stored_url"

      expect(controller.send(:after_authentication_url)).to eq("/some_stored_url")
      expect(controller.session[:return_to_after_authenticating]).to be_nil
    end

    it "uses determine_redirect_url_for when no stored URL in session" do
      allow(Current).to receive(:session).and_return(session)
      allow(Current.session).to receive(:user).and_return(user)

      expect(controller).to receive(:determine_redirect_url_for).with(user).and_return("/determined_url")
      expect(controller.send(:after_authentication_url)).to eq("/determined_url")
    end
  end

  describe "determine_redirect_url_for method" do
    it "redirects to admin dashboard for admin users" do
      expect(controller.send(:determine_redirect_url_for, admin_user)).to eq(admin_dashboard_index_url)
    end

    it "redirects to root url for non-admin users" do
      expect(controller.send(:determine_redirect_url_for, user)).to eq(root_url)
    end
  end

  describe "protect_client_access method" do
    context "when not authenticated" do
      include_context "not authenticated"

      it "redirects to root_url" do
        expect(controller).to receive(:redirect_to).with(root_url)
        controller.send(:protect_client_access)
      end
    end

    context "when authenticated as client" do
      include_context "authenticated as client"

      it "redirects to root_url" do
        expect(controller).to receive(:redirect_to).with(root_url)
        controller.send(:protect_client_access)
      end
    end

    context "when authenticated as admin" do
      include_context "authenticated as admin"

      it "allows the request to proceed without redirection" do
        expect(controller).not_to receive(:redirect_to)
        controller.send(:protect_client_access)
      end
    end
  end

  describe "protect_admin_access method" do
    context "when not authenticated" do
      include_context "not authenticated"

      it "redirects to admin_dashboard_index_url" do
        expect(controller).to receive(:redirect_to).with(admin_dashboard_index_url)
        controller.send(:protect_admin_access)
      end
    end

    context "when authenticated as admin" do
      include_context "authenticated as admin"

      it "redirects to admin_dashboard_index_url" do
        expect(controller).to receive(:redirect_to).with(admin_dashboard_index_url)
        controller.send(:protect_admin_access)
      end
    end

    context "when authenticated as client" do
      include_context "authenticated as client"

      it "allows the request to proceed without redirection" do
        expect(controller).not_to receive(:redirect_to)
        expect(controller.send(:protect_admin_access)).to be_nil
      end
    end
  end
end
