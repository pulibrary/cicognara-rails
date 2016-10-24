class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.string :section_head
      t.string :section_display
      t.string :section_number
      t.string :n_value
      t.string :entry_id
      t.text :tei

      t.timestamps
    end
    add_index :entries, :n_value
    add_index :entries, :entry_id
  end
end
