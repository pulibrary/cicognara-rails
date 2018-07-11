class AddIiifResourceRefToBooks < ActiveRecord::Migration[5.1]
  def change
    add_reference :books, :iiif_resource, foreign_key: true
  end
end
