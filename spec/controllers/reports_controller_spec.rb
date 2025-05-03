require 'rails_helper'

describe ReportsController do
  let(:user) { create(:user) }
  let(:area) { create(:area) }
  let(:report) { create(:report) }

  before do
    allow(Current).to receive(:user).and_return(user)
    area_coordinates = JSON.parse(area.coordinates)
    allow(area).to receive(:coordinates).and_return(area_coordinates)
    create(:area_report, area: area, report: report)
    create(:user_area, user: user, area: area)
    user.areas << area
  end

  describe 'GET #index' do
    context 'when user has areas' do
      # it 'assigns a new report and user areas' do
      #   get :index
      #   expect(assigns(:report)).to be_a_new(Report)
      #   expect(assigns(:user_areas)).to eq(user.areas.sorted_by_created_at.map { |area| { "#{area.id}" => area.coordinates } }.to_json)
      #   expect(response).to have_http_status(:success)
      # end
    end

    context 'when user has no areas' do
      it 'redirects to root_path' do
        user.areas.destroy_all
        get :index
        expect(response).to redirect_to(new_session_url)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      # it 'creates a new report' do
      #   expect {
      #     post :create, params: { report: report }
      #   }.to change(Report, :count).by(1)
      # end

      # it 'redirects to root_path with a notice' do
      #   post :create, params: { report: report }
      #   expect(response).to redirect_to(new_session_url)
      #   expect(flash[:notice]).to eq("Test Location")
      # end
    end

    context 'with invalid parameters' do
      it 'does not create a new report' do
        expect {
          post :create, params: { report: { lat: nil, long: nil } }
        }.not_to change(Report, :count)
      end
    end
  end
end
