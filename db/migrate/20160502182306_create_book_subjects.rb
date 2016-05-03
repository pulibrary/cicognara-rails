class CreateBookSubjects < ActiveRecord::Migration
  def change
    create_table :book_subjects do |t|
      t.references :book, index: true, foreign_key: true
      t.references :subject, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
