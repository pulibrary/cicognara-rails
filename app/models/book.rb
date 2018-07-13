class Book < ActiveRecord::Base
  # Descriptive metadata (MARC record) relationship
  has_one :marc_record

  # Descriptive metadata authority relationships
  #has_many :creator_roles
  has_and_belongs_to_many :creators
  #has_many :book_subjects
  #has_many :subjects, through: :book_subjects
  has_and_belongs_to_many :subjects, join_table: :book_subjects

  # Relationship to the parent Entry (modeling the entity encoded in the TEI)
  #has_many :entry_books
  #has_many :entries, through: :entry_books
  belongs_to :entry

  # Relationship to the physical items (e. g. volumes) for the book
  has_many :volumes

  has_many :versions, through: :volumes
  #has_many :contributing_libraries, through: :versions
  def contributing_libraries
    versions.map(&:contributing_library)
  end

  def to_solr
    ::Cicognara::BookIndexer.new(self).to_solr.values.first.merge(extra_solr)
  end

  def extra_solr
    {
      'contributing_library_facet' => contributing_libraries.map(&:label),
      'digitized_version_available_facet' => [digitized_version_available?],
      'manifests_s' => versions.map(&:manifest)
    }
  end

  def digitized_version_available?
    versions.empty? ? 'No' : 'Yes'
  end

  def marcxml
    marc_record.source
  end

  def digital_cico_numbers
    volumes.map(&:digital_cico_number)
  end
end
