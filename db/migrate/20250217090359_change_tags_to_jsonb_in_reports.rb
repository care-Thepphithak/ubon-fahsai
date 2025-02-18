class ChangeTagsToJsonbInReports < ActiveRecord::Migration[8.0]
  def change
    change_column :reports, :tags, :jsonb, default: [], using: 'tags::jsonb'
  end
end
