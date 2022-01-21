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
      index_versions!
    end

    # Appends a few fields from the Version table to the Book documents in Solr.
    # This makes sure that links to "search by facet" from the Show page (that displays Version data)
    # result in successful searches againsts the Book data in Solr.
    # rubocop:disable Metrics/AbcSize
    def index_versions!
      Rails.logger.info "Updating Solr docs with Version data at #{Time.zone.now}"
      Version.all.each do |version|
        names = (version.imported_metadata['related_name_display'] || []) + (version.imported_metadata['author_display'] || []).uniq
        update_related_names(version.book.digital_cico_number, names) if names.present?
      end
      solr.commit
      Rails.logger.info "Done updating Solr docs with Version data at #{Time.zone.now}"
    end
    # rubocop:enable Metrics/AbcSize

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

    # Finds the Book document IDs for a given Cicognara number.
    def book_ids_for_digital_cico_number(digital_cico_number)
      response = solr.get 'select', params: { q: "alt_id:\"#{digital_cico_number}\" -format:marc", defType: 'edismax' }
      ids = response['response']['docs'].map { |doc| doc['id'] }
      ids
    end

    # Performs an atomic update to add-distinc values to the name_facets field
    # See https://github.com/rsolr/rsolr/issues/137 and https://solr.apache.org/guide/8_4/updating-parts-of-documents.html
    def update_related_names(digital_cico_number, names)
      ids = book_ids_for_digital_cico_number(digital_cico_number)
      if ids.count.zero?
        Rails.logger.warn "No Solr documents found for #{digital_cico_number}."
        return
      end

      ids.each do |id|
        data = [{ id: id, name_facet: { 'add-distinct' => names } }]
        headers = { 'Content-Type' => 'application/json' }
        result = solr.update(data: data.to_json, headers: headers)
        Rails.logger.warn "Error updating #{digital_cico_number} (#{id})" if result['responseHeader']['status'] != 0
      end
    end
  end
end
