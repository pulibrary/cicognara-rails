class AddMarcRecordToBooks < ActiveRecord::Migration[5.1]
  def change
    change_table :books do |t|
      t.references :marc_record, index: true, foreign_key: true
    end
  end
end
