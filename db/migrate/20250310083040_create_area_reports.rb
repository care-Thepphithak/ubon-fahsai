class CreateAreaReports < ActiveRecord::Migration[8.0]
  def change
    create_table :area_reports do |t|
      t.references :area, null: false, foreign_key: true
      t.references :report, null: false, foreign_key: true

      t.timestamps
    end
  end
end
