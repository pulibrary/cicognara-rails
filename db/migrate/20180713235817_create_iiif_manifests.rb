class CreateIiifManifests < ActiveRecord::Migration[5.1]
  def change
    create_table :iiif_manifests do |t|
      t.string :uri
      t.string :label
      #t.belongs_to :version, index: true
      t.references :version, foreign_key: true

      t.timestamps
    end
  end
end
