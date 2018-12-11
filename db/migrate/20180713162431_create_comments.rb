class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :entry, foreign_key: true
      t.string :text
      t.datetime :timestamp
      t.integer :user_id

      t.timestamps
    end
  end
end
