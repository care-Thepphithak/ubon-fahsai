require 'rails_helper'

describe SessionsController do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user, ip_address: "127.0.0.1", user_agent: "TestAgent") }

  describe "GET #new" do
    context "when authenticated" do
      before do
        cookies.signed[:session_id] = session.id
        allow(Session).to receive(:find_by).and_return(session)
      end

      it "redirects to the after authentication URL" do
        allow(Current).to receive(:session).and_return(session)

        get :new
        after_authenticated_url = controller.send(:after_authentication_url)
        expect(response).to redirect_to(after_authenticated_url)
      end
    end

    context "when not authenticated" do
      it "renders the new session page" do
        get :new
        expect(response).to be_successful
      end
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      let(:valid_login_credentials) { { email_address: user.email_address, password: user.password } }
      let(:permitted_params) { ActionController::Parameters.new(valid_login_credentials).permit(:email_address, :password) }

      it "starts a new session and redirects to the after authentication URL" do
        allow(Current).to receive(:session).and_return(session)

        expect(User).to receive(:authenticate_by).with(permitted_params).and_return(user)
        expect(controller).to receive(:start_new_session_for).with(user)

        post :create, params: valid_login_credentials

        expect(response).to redirect_to(controller.send(:after_authentication_url))
      end
    end

    context "with invalid credentials" do
      let(:invalid_login_credentials) { { email_address: "non.existing.mail@example.com", password: "wrongPassword" } }

      it "redirects to the new session path with an alert" do
        expect(User).to receive(:authenticate_by).and_return(nil)

        post :create, params: invalid_login_credentials
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("อีเมลหรือรหัสผ่านไม่ถูกต้อง")
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      cookies.signed[:session_id] = session.id
      allow(Session).to receive(:find_by).and_return(session)
    end

    it "terminates the session and redirects to the new session path" do
      expect(controller).to receive(:terminate_session)

      delete :destroy
      expect(response).to redirect_to(new_session_path)
    end
  end
end
