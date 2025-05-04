require 'rails_helper'

describe ReportsController do
  let(:user) { create(:user) }
  let(:area) { create(:area) }
  let(:report) { create(:report) }
  let(:session) { create(:session, user: user, ip_address: "127.0.0.1", user_agent: "TestAgent") }

  before do
    allow(Current).to receive(:user).and_return(user)
    cookies.signed[:session_id] = session.id
    allow(Session).to receive(:find_by).and_return(session)

    area_coordinates = JSON.parse(area.coordinates)
    allow(area).to receive(:coordinates).and_return(area_coordinates)
    create(:area_report, area: area, report: report)
    create(:user_area, user: user, area: area)
    user.areas << area
  end

  describe 'GET #index' do
    context 'when user has areas' do
      it 'assigns user areas as JSON' do
        get :index
        expect(assigns(:user_areas)).to eq(user.areas.sorted_by_created_at.map { |area| { "#{area.id}" => area.coordinates } }.to_json)
      end
    end

    context 'when user has no areas' do
      it 'redirects to root_path' do
        user.areas.destroy_all
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST #create' do
  context 'with valid parameters' do
    let(:valid_attributes) do
      {
        lat: "-255.1196925",
        long: "15.2304411",
        location_name: "Test Location",
        description: "Test Description",
        severity_level: "รุนแรง",
        tags: [ "tag1", "tag2" ],
        area_ids: area.id.to_s,
        images: []
      }
    end

    it 'creates a new report' do
      expect {
        post :create, params: { report: valid_attributes }
      }.to change(Report, :count).by(1)
    end
  end

  context 'with invalid parameters' do
    let(:invalid_attributes) do
      {
        lat: nil,
        long: nil,
        location_name: nil,
        description: nil,
        severity_level: nil,
        tags: nil,
        area_ids: nil,
        images: []
      }
    end

    # it 'does not create a new report' do
    #   expect {
    #     post :create, params: { report: invalid_attributes }
    #   }.not_to change(Report, :count)
    # end

    it 'renders the turbo_stream response with errors' do
      post :create, params: { report: invalid_attributes }, format: :turbo_stream
      expect(response.content_type).to eq('text/vnd.turbo-stream.html; charset=utf-8')
    end
  end
end
end
