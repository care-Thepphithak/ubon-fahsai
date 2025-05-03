require "rails_helper"

describe Authentication do
  controller(ActionController::Base) do
    include Authentication
  end

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:session) { create(:session, user: user, ip_address: "127.0.0.1", user_agent: "TestAgent") }
  let(:admin_session) { create(:session, user: admin_user, ip_address: "127.0.0.1", user_agent: "TestAgent") }

  describe "#request_authentication" do
    it "stores return_to_after_authenticating in session and redirects to new_session_path" do
      allow(controller.request).to receive(:url).and_return("http://test.host/protected")

      expect(controller).to receive(:redirect_to).with(controller.new_session_path)
      controller.send(:request_authentication)

      expect(controller.session[:return_to_after_authenticating]).to eq("http://test.host/protected")
    end
  end

  describe "#after_authentication_url" do
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

  describe "#determine_redirect_url_for" do
    it "redirects to admin dashboard for admin users" do
      expect(controller.send(:determine_redirect_url_for, admin_user)).to eq(admin_dashboard_index_url)
    end

    it "redirects to root url for non-admin users" do
      expect(controller.send(:determine_redirect_url_for, user)).to eq(root_url)
    end
  end

  describe "#protect_client_access" do
    context "when not authenticated" do
      before do
        allow(controller).to receive(:authenticated?).and_return(false)
      end

      it "redirects to root_url" do
        expect(controller).to receive(:redirect_to).with(root_url)
        controller.send(:protect_client_access)
      end
    end

    context "when authenticated but not admin" do
      before do
        allow(controller).to receive(:authenticated?).and_return(true)
        allow(Current).to receive(:session).and_return(session)
        allow(Current.session).to receive(:user).and_return(user)
      end

      it "redirects to root_url" do
        expect(controller).to receive(:redirect_to).with(root_url)
        controller.send(:protect_client_access)
      end
    end

    context "when authenticated as admin" do
      before do
        allow(controller).to receive(:authenticated?).and_return(true)
        allow(Current).to receive(:session).and_return(admin_session)
        allow(Current.session).to receive(:user).and_return(admin_user)
      end

      it "allows admin and then protect_client_access return nil" do
        expect(controller).not_to receive(:redirect_to)
        controller.send(:protect_client_access)
      end
    end
  end

  # describe "#protect_admin_access" do
  #   context "when not authenticated" do
  #     before do
  #       allow(controller).to receive(:authenticated?).and_return(false)
  #     end

  #     it "calls request_authentication" do
  #       expect(controller).to receive(:request_authentication)
  #       controller.protect_admin_access
  #     end
  #   end

  #   context "when authenticated as admin" do
  #     before do
  #       allow(controller).to receive(:authenticated?).and_return(true)
  #       allow(Current).to receive(:session).and_return(admin_session)
  #       allow(Current.session).to receive(:user).and_return(admin_user)
  #       allow(Current.session.user).to receive(:admin?).and_return(true)
  #     end

  #     it "does not redirect" do
  #       expect(controller).not_to receive(:redirect_to)
  #       controller.protect_admin_access
  #     end
  #   end

  #   context "when authenticated but not admin" do
  #     before do
  #       allow(controller).to receive(:authenticated?).and_return(true)
  #       allow(Current).to receive(:session).and_return(session)
  #       allow(Current.session).to receive(:user).and_return(user)
  #       allow(Current.session.user).to receive(:admin?).and_return(false)
  #     end

  #     it "redirects to admin_dashboard_index_url" do
  #       expect(controller).to receive(:redirect_to).with(controller.admin_dashboard_index_url)
  #       controller.protect_admin_access
  #     end
  #   end
  # end
end
