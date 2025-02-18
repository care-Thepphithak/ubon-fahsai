class AddFieldsToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :description, :text
    add_column :reports, :tags, :text
    add_column :reports, :severity_level, :string
  end
end
