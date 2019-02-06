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

  def extra_solr
    {
      'contributing_library_facet' => contributing_libraries.map(&:label),
      'digitized_version_available_facet' => digitized_version_available,
      'manifests_s' => manifests,
      'text' => range_labels_from_manifests,
      'book_id_s' => [id]
    }
  end

  def manifests
    @manifests ||= versions.map(&:manifest)
  end

  def range_labels_from_manifests
    manifests.map do |url|
      begin
        manifest_response = Faraday.get(url)
        json = JSON.parse(manifest_response.body)
        json['structures'].map { |s| s['label'] } if json['structures']
      rescue StandardError
        []
      end
    end.flatten
  end

  def digitized_version_available
    return ['None'] if versions.empty?
    versions.map { |v| v.based_on_original? ? 'Microfiche' : 'Matching copy' }
  end
end
