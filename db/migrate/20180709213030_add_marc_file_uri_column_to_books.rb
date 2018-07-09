class AddMarcFileUriColumnToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :marc_file_uri, :string
  end
end
