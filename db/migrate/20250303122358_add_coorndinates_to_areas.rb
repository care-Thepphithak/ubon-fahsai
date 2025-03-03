class AddCoorndinatesToAreas < ActiveRecord::Migration[8.0]
  def change
    add_column :areas, :coordinates, :jsonb, default: [], using: 'coordinates::jasonb'
  end
end
