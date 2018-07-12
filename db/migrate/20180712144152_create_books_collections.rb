class CreateBooksCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :books_collections do |t|
      t.belongs_to :book, index: true
      t.belongs_to :collection, index: true
    end
  end
end
