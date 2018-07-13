class CreateVolumes < ActiveRecord::Migration[5.1]
  def change
    create_table :volumes do |t|
      t.string :digital_cico_number
      t.belongs_to :book, index: true

      t.timestamps
    end
  end
end
