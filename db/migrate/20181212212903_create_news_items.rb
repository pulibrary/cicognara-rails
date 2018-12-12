class CreateNewsItems < ActiveRecord::Migration[5.1]
  def change
    create_table :news_items do |t|
      t.string :body
      t.datetime :timestamp
      t.string :title
      t.integer :user_id

      t.timestamps
    end
  end
end
