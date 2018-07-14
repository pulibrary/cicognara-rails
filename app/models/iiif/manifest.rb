module IIIF
  class Manifest < ApplicationRecord
    def self.table_name_prefix
      'iiif_'
    end

    #def self.build_presentation(iiif_manifest, uri = nil, label = nil)
    def self.build_presentation(iiif_manifest)
      #iiif_manifest.uri = uri
      #iiif_manifest.label = "Version #{index + 1}"
      #iiif_manifest.save

      IIIF::Presentation::Manifest.new.tap do |p|
        p["@id"] = iiif_manifest.uri
        p["label"] = iiif_manifest.label
      end
    end

    #has_one :version
    belongs_to :version

  end
end
