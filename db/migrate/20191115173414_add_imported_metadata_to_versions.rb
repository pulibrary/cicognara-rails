class AddImportedMetadataToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :imported_metadata, :text
  end
end
