class Book < ActiveRecord::Base
  has_many :creator_roles
  has_many :book_subjects
  has_many :subjects, through: :book_subjects
  has_many :entry_books
  has_many :entries, through: :entry_books
  has_many :versions
  has_many :contributing_libraries, through: :versions
  belongs_to :iiif_resource, class_name: "IIIF::Resource"
  has_and_belongs_to_many :collections

  attribute :marcxml, :marc_nokogiri_type
  validates :digital_cico_number, presence: true

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
end
