class RemoveAreaIdFromReports < ActiveRecord::Migration[8.0]
  def change
    remove_column :reports, :area_id, :integer
  end
end
