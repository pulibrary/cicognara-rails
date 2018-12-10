require './app/models/book'
require './app/models/contributing_library'

module Cicognara
  class CSVMapper
    def self.map(row)
      mapped_keys = %w(based_on_original contributing_library digital_cico_number)
      {
        book: find_book(row['digital_cico_number']),
        contributing_library: map_reference(ContributingLibrary, 'label', row['contributing_library']),
        based_on_original: row['based_on_original'] == 'TRUE'
      }.merge(row.keep_if { |k, _v| !mapped_keys.include? k })
    end

    def self.map_reference(model, field, label)
      result = model.where(field => label).first
      raise(ArgumentError, "#{model} not found '#{label}'") unless result
      result
    end

    def self.find_book(digital_cico_number)
      solr_client = Blacklight.default_index.connection
      response = solr_client.get('select', params: { q: "dclib_s\\:#{digital_cico_number}", fl: 'book_id_s' })
      documents = response['response']['docs']
      raise(ArgumentError, "Book not found '#{digital_cico_number}'") if documents.empty?

      document = documents.first
      book_id = document['book_id_s']
      Book.find_by(id: book_id)
    end
  end
end
