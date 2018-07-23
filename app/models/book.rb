class Book < ActiveRecord::Base
  # Descriptive metadata (MARC record) relationship
  has_one :marc_record, dependent: :destroy

  # Descriptive metadata authority relationships
  has_and_belongs_to_many :creators
  has_and_belongs_to_many :subjects, join_table: :book_subjects

  # Relationship to the parent Entry (modeling the entity encoded in the TEI)
  belongs_to :entry

  # Relationship to the physical items (e. g. volumes) for the book
  has_many :volumes, dependent: :destroy

  has_many :versions, through: :volumes, dependent: :destroy

  # Access the contributing libraries referenced in the versions for the Book
  # @return [Array<ContributingLibrary>]
  def contributing_libraries
    versions.map(&:contributing_library)
  end

  def extra_solr
    {
      'contributing_library_facet' => contributing_libraries.map(&:label),
      'digitized_version_available_facet' => [digitized_version_available?],
      'manifests_s' => versions.map(&:manifest)
    }
  end

  # Generate the Solr Document used for indexing a Book
  # @return [Hash]
  def to_solr
    ::Cicognara::BookIndexer.new(self).to_solr.values.first.merge(extra_solr)
  end

  # Determine whether or not a digitized version for this Book exists in the system
  # @return [String]
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
