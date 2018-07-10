class CreateCreators < ActiveRecord::Migration[5.0]
  def change
    create_table :creators do |t|
      t.string :label
      t.string :uri

      t.timestamps null: false
    end
  end
end
