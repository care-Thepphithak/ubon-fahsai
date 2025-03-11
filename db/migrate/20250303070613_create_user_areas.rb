class CreateUserAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :user_areas do |t|
      t.references :user, null: false, foreign_key: true
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
  end
end
