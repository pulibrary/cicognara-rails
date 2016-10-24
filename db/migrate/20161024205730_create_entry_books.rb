class CreateEntryBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :entry_books do |t|
      t.references :book, foreign_key: true
      t.references :entry, foreign_key: true

      t.timestamps
    end
  end
end
