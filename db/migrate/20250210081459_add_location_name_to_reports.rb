class AddLocationNameToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :location_name, :string
  end
end
