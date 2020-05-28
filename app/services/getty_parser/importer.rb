class GettyParser
  class Importer
    attr_reader :records
    def initialize(records:)
      @records = records
    end

    # Delete all old versions in a transaction, process all the getty records to
    # create Versions from them, and then reindex all existing Books + Entries
    # at the end so there's no time where there's no versions in the interface.
    def import!
      Version.transaction do
        Version.delete_all
        records.each do |record|
          begin
            import_record(record)
          rescue ActiveRecord::RecordNotFound
            Rails.logger.warn "Unable to import #{record.primary_identifier} - no matching Book entry for DCL dcl:#{record.dcl_number}"
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.warn "Unable to import #{record.primary_identifier} - failed validations: #{e}"
          end
        end
      end
      reindex!
    end

    def reindex!
      entry_indexer = Cicognara::BulkEntryIndexer.new(Entry.all.to_a)
      solr.add(entry_indexer.book_documents + entry_indexer.entry_documents)
      solr.commit
    end

    def import_record(record)
      book = Book.where(digital_cico_number: "dcl:#{record.dcl_number}").first!
      contributing_library = ContributingLibrary.find_or_create_by(label: record.contributing_institution, uri: 'https://example.com')
      record.manifest_urls.each do |manifest_url|
        version = create_version(record, manifest_url)
        version.book = book
        version.contributing_library = contributing_library
        version.save!
        Rails.logger.info "Imported #{record.primary_identifier} as Version #{version.id}"
      end
    end

    def create_version(record, manifest_url)
      version = Version.find_or_initialize_by(
        owner_system_number: record.primary_identifier,
        manifest: manifest_url
      )
      version.label = record.title
      version.based_on_original = false
      version.rights = record.rights_statement
      version.imported_metadata = record.imported_metadata
      version
    end

    def solr
      Blacklight.default_index.connection
    end
  end
end
