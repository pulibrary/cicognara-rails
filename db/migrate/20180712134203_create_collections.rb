class CreateCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :collections do |t|
      t.string :slug
    end
  end
end
