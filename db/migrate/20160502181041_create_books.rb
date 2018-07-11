class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :marcxml
      t.string :digital_cico_number

      t.timestamps null: false
    end
  end
end
