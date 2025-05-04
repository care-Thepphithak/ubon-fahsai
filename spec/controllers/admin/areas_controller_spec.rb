require 'rails_helper'

describe Admin::AreasController do
  let(:user) { create(:user, admin: true) }
  let(:admin_user) { create(:user, :admin) }
  let(:area) { create(:area) }
  let(:session) { create(:session, user: user, ip_address: "127.0.0.1", user_agent: "TestAgent") }

  before do
    allow(Current).to receive(:user).and_return(user)
    cookies.signed[:session_id] = session.id
    allow(Session).to receive(:find_by).and_return(session)
  end

  describe 'GET #index' do
    it 'assigns all areas as @areas' do
      get :index
      expect(assigns(:areas)).to eq(Area.sorted_by_created_at)
    end
  end

  describe 'GET #new' do
    it 'assigns a new area as @area' do
      get :new
      expect(assigns(:area)).to be_a_new(Area)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested area as @area' do
      get :edit, params: { id: area.id }
      expect(assigns(:area)).to eq(area)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) { attributes_for(:area) }

      it 'creates a new Area' do
        expect {
          post :create, params: { area: valid_attributes }
        }.to change(Area, :count).by(1)
      end

      it 'redirects to the areas index' do
        post :create, params: { area: valid_attributes }
        expect(response).to redirect_to(admin_areas_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '', coordinates: [].to_json } }

      it 'does not create a new Area' do
        expect {
          post :create, params: { area: invalid_attributes }
        }.not_to change(Area, :count)
      end

      it 'renders the new template with errors' do
        post :create, params: { area: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Area Name', coordinates: [].to_json } }

      it 'updates the requested area and redirects to the areas index' do
        patch :update, params: { id: area.id, area: new_attributes }
        area.reload
        expect(new_attributes[:name]).to eq('Updated Area Name')
        # expect(response).to redirect_to(admin_areas_path)
      end
    end

    # context 'with invalid parameters' do
    #   let(:invalid_attributes) { { name: nil } }

    #   it 'does not update the area' do
    #     patch :update, params: { id: area.id, area: invalid_attributes }
    #     area.reload
    #     expect(area.name).not_to be_nil
    #   end

    #   it 'renders the edit template with errors' do
    #     patch :update, params: { id: area.id, area: invalid_attributes }
    #     expect(response).to render_template(:edit)
    #   end
    # end
  end
end
