class AddAreaToReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :reports, :area, null: false, foreign_key: true
  end
end
