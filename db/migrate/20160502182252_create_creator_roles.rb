class CreateCreatorRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :creator_roles do |t|
      t.references :book, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: true
      t.references :role, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
