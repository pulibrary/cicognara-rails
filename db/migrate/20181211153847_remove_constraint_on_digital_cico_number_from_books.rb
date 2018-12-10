class RemoveConstraintOnDigitalCicoNumberFromBooks < ActiveRecord::Migration[5.1]
  def up
    change_table :books do |t|
      t.remove :digital_cico_number
    end
  end

  def down
    change_table :books do |t|
      t.string :digital_cico_number
    end
    add_index :books, :digital_cico_number, unique: true
  end
end
