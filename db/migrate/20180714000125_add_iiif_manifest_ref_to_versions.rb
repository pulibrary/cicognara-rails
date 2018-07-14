class AddIiifManifestRefToVersions < ActiveRecord::Migration[5.1]
  def change
    add_reference :versions, :iiif_manifest, foreign_key: true
  end
end
