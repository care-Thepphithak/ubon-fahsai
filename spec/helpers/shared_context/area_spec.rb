RSpec.shared_context 'area' do
  before do
    @area = Area.create!(
      name: "Test Area 1",
      created_at: "2021-06-02 00:00:00",
      updated_at: "2021-06-02 00:00:00",
      coordinates: [ [ 15.216737857245673, 104.86441710314403 ], [ 15.219926459031183, 104.86705846834863 ], [ 15.217855943886963, 104.86662897807143 ] ]
    )
  end
end
