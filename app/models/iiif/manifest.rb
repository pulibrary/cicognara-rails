module IIIF
  class Manifest < ApplicationRecord
    def self.table_name_prefix
      'iiif_'
    end

    belongs_to :version

    delegate :to_json, to: :manifest_values

    # private

    def manifest_values
      @manifest_values ||= IIIF::Presentation::Manifest.new.tap do |p|
        p['@id'] = uri
        p['label'] = label
      end
    end
  end
end
