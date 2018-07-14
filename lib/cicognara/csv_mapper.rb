require './app/models/book'
require './app/models/contributing_library'

module Cicognara
  class CSVMapper
    def self.map(row, row_index = 0)
      mapped_keys = %w(based_on_original contributing_library digital_cico_number manifest)
      {
        book: map_reference(Book, 'digital_cico_number', row['digital_cico_number']),
        contributing_library: map_reference(ContributingLibrary, 'label', row['contributing_library']),
        based_on_original: row['based_on_original'] == 'TRUE',
        iiif_manifest: build_iiif_manifest(row["manifest"], row_index)
      }.merge(row.keep_if { |k, _v| !mapped_keys.include? k })
    end

    def self.map_reference(model, field, label)
      result = model.where(field => label).first
      raise(ArgumentError, "#{model} not found '#{label}'") unless result
      result
    end

    def self.build_iiif_manifest(uri, index)
      label = "Version #{index}"
      IIIF::Manifest.first_or_create(uri: uri, label: label)
    end
  end
end
