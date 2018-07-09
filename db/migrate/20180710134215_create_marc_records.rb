class CreateMarcRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :marc_records do |t|
      t.string :file_uri
      t.text :source
      t.references :book, index: true, foreign_key: true

      t.timestamps
    end
    add_index :marc_records, :file_uri
  end
end
