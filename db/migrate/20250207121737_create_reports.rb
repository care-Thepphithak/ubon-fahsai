class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :lat
      t.string :long

      t.timestamps
    end
  end
end
