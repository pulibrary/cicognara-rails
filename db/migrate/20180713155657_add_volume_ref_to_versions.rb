class AddVolumeRefToVersions < ActiveRecord::Migration[5.1]
  def change
    add_reference :versions, :volume, foreign_key: true
  end
end
