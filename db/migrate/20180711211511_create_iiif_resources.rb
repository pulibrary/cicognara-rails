class CreateIiifResources < ActiveRecord::Migration[5.1]
  def change
    create_table :iiif_resources do |t|
      t.string :url
    end
  end
end
