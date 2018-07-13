class CreateJoinTableBooksCreators < ActiveRecord::Migration[5.1]
  def change
    create_join_table :books, :creators do |t|
      t.references :book, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: true
    end
  end
end
