class AddDcNumToBook < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :dc_num, :string
    add_index :books, :dc_num, unique: true
  end
end
