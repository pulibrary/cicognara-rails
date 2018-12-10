module Cicognara
  class BookIndexer
    attr_reader :books
    def initialize(books)
      @books = Array(books)
    end

    def to_solr
      marc_solr
    end

    private

      def marc_solr
        processed_documents = []
        marc_records.each do |marc_record|
          marc_record.reload
          processed_documents << Tempfile.open('book_marc') do |f|
            marc_document = marc_collection(marc_record.source)
            f.write(marc_document)
            f.close
            indexer.process(f.path, marc_record.file_uri)
            indexer.writer.all_records
          end
        end

        @marc_solr = {}
        marc_values = processed_documents.first
        marc_values.each_pair do |marc_key, marc_document|
          @marc_solr[marc_key] = marc_document
        end

        @marc_solr
      end

      def indexer
        @indexer ||=
          MarcIndexer.new.tap do |i|
            i.writer = SolrWriterAccumulator.new(i.settings)
          end
      end

      def marc_records
        books.map(&:marc_record)
      end

      def marc_documents
        marc_docs = books.map(&:marcxml)
        marc_docs.map(&:clone)
      end

      def marc_collection(document)
        collection = Nokogiri::XML('<marc:collection xmlns:marc="http://www.loc.gov/MARC21/slim"></marc:collection>')
        return unless document.root.present?
        collection.root << document.root.clone
        collection.to_xml
      end
  end
end
