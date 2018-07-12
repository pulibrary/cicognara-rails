module IIIF
  class Resource < ActiveRecord::Base
    has_one :book, foreign_key: "iiif_resource_id"

    def self.table_name_prefix
      'iiif_'
    end
  end
end
