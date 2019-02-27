class AddOcrTextToVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :versions, :ocr_text, :text
  end
end
