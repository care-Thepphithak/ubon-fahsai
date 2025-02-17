class ChangeTagsToTextInReports < ActiveRecord::Migration[8.0]
  def change
    change_column :reports, :tags, :text
  end
end
