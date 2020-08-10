require './app/models/book'
require './app/models/contributing_library'

module Cicognara
  class CSVMapper
    def self.map(row)
      mapped_keys = %w(based_on_original contributing_library digital_cico_number)
      {
        book: map_reference(Book, 'digital_cico_number', row['digital_cico_number']),
        contributing_library: map_reference(ContributingLibrary, 'label', row['contributing_library']),
        based_on_original: row['based_on_original'] == 'TRUE'
      }.merge(row.keep_if { |k, _v| !mapped_keys.include? k })
    end

    def self.map_reference(model, field, label)
      result = model.where(field => label).first
      raise(ArgumentError, "#{model} not found '#{label}'") unless result

      result
    end
  end
end
