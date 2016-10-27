class AddIndexToBook < ActiveRecord::Migration[5.0]
  def change
    add_index :books, :digital_cico_number, unique: true    
  end
end
