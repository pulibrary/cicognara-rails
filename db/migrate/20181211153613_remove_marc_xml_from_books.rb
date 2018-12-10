class RemoveMarcXmlFromBooks < ActiveRecord::Migration[5.1]
  def up
    change_table :books do |t|
      t.remove :marcxml
    end
  end

  def down
    change_table :books do |t|
      t.string :marcxml
    end
  end
end
