class CreateContributingLibraries < ActiveRecord::Migration
  def change
    create_table :contributing_libraries do |t|
      t.string :label
      t.string :uri

      t.timestamps null: false
    end
  end
end
