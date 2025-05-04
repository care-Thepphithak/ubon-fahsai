shared_context "not authenticated" do
  before do
    allow(controller).to receive(:authenticated?).and_return(false)
  end
end

shared_context "authenticated as client" do
  before do
    allow(controller).to receive(:authenticated?).and_return(true)
    allow(Current).to receive(:session).and_return(session)
    allow(Current.session).to receive(:user).and_return(user)
  end
end

shared_context "authenticated as admin" do
  before do
    allow(controller).to receive(:authenticated?).and_return(true)
    allow(Current).to receive(:session).and_return(admin_session)
    allow(Current.session).to receive(:user).and_return(admin_user)
  end
end
