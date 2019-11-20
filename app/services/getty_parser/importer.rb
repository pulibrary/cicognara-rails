class GettyParser
  class Importer
    attr_reader :records
    def initialize(records:)
      @records = records
    end

    def import!
      records.each do |record|
        Version.transaction do
          begin
            import_record(record)
          rescue ActiveRecord::RecordNotFound
            Rails.logger.warn "Unable to import #{record.primary_identifier} - no matching Book entry for DCL dcl:#{record.dcl_number}"
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.warn "Unable to import #{record.primary_identifier} - failed validations: #{e}"
          end
        end
      end
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
      Rails.logger.info "Imported #{record.primary_identifier}"
    end

    def populate_version(version, record)
      version.manifest = record.manifest_url
      version.label = record.title
      version.based_on_original = false
      version.rights = record.rights_statement
      version.imported_metadata = record.imported_metadata
    end
  end
end
