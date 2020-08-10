class Book < ActiveRecord::Base
  has_many :creator_roles
  has_many :book_subjects
  has_many :subjects, through: :book_subjects
  has_many :entry_books
  has_many :entries, through: :entry_books
  has_many :versions
  has_many :contributing_libraries, through: :versions
  attribute :marcxml, :marc_nokogiri_type

  def to_solr
    ::Cicognara::BookIndexer.new(self).to_solr.values.first.merge(extra_solr)
  end

  def unique_versions
    versions.order(:id).uniq(&:owner_system_number)
  end

  def extra_solr
    {
      'contributing_library_facet' => contributing_libraries.map(&:label),
      'digitized_version_available_facet' => digitized_version_available,
      'manifests_s' => manifests,
      'text' => manifest_content,
      'book_id_s' => [id]
    }
  end

  def manifests
    @manifests ||= versions.map(&:manifest)
  end

  # Index manifest range labels and OCR which is cached in Version#ocr_text.
  def manifest_content
    versions.flat_map(&:ocr_text).compact
  end

  def digitized_version_available
    return ['None'] if versions.empty?

    versions.map { |v| v.based_on_original? ? 'Microfiche' : 'Matching copy' }
  end
end
