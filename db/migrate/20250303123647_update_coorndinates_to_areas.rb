class UpdateCoorndinatesToAreas < ActiveRecord::Migration[8.0]
  def change
        change_column :areas, :coordinates, :jsonb, default: [], using: 'coordinates::jsonb'
  end
end
