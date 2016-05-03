class CreateCreators < ActiveRecord::Migration
  def change
    create_table :creators do |t|
      t.string :label
      t.string :uri

      t.timestamps null: false
    end
  end
end
