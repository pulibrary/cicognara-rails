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
      version_entries = Version.includes(book: [{ entries: :books }, :contributing_libraries, :versions]).map(&:book).flat_map(&:entries)
      bulk_indexer = Cicognara::BulkEntryIndexer.new(version_entries)
      solr.add(bulk_indexer.book_documents + bulk_indexer.entry_documents)
      solr.commit
    end

    def import_record(record)
      book = Book.where(digital_cico_number: "dcl:#{record.dcl_number}").first!
      contributing_library = ContributingLibrary.find_or_create_by(label: record.contributing_institution, uri: 'https://example.com')
      version = Version.find_or_initialize_by(
        owner_system_number: record.primary_identifier
      )
      populate_version(version, record)
      version.book = book
      version.contributing_library = contributing_library
      version.save!
      Rails.logger.info "Imported #{record.primary_identifier} as Version #{version.id}"
    end

    def populate_version(version, record)
      version.manifest = record.manifest_url
      version.label = record.title
      version.based_on_original = false
      version.rights = record.rights_statement
      version.imported_metadata = record.imported_metadata
    end

    def solr
      Blacklight.default_index.connection
    end
  end
end
