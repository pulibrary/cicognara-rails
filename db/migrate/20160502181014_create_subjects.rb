class CreateSubjects < ActiveRecord::Migration[5.0]
  def change
    create_table :subjects do |t|
      t.string :label
      t.string :uri
      t.string :genre
      t.string :geographic
      t.string :name
      t.string :temporal
      t.string :topic

      t.timestamps null: false
    end
  end
end
