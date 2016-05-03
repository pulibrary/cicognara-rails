class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :marcxml
      t.string :digital_cico_number

      t.timestamps null: false
    end
  end
end
