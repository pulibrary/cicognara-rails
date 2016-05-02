class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.references :contributing_library, index: true, foreign_key: true
      t.references :book, index: true, foreign_key: true
      t.string :owner_call_number
      t.string :owner_system_number
      t.string :other_number
      t.string :label
      t.string :version_edition_statement
      t.string :version_publication_statement
      t.string :version_publication_date
      t.string :additional_responsibility
      t.string :provenance
      t.string :physical_characteristics
      t.string :rights
      t.boolean :based_on_original
      t.string :manifest

      t.timestamps null: false
    end
  end
end
