class Book < ActiveRecord::Base
  has_many :creator_roles
  has_many :book_subjects
  has_many :subjects, through: :book_subjects
  has_many :entry_books
  has_many :entries, through: :entry_books
  has_many :versions
  has_many :contributing_libraries, through: :versions
  attribute :marcxml, :marc_nokogiri_type

  # Retrieve a IIIF Manifest from a URL
  # @param url [String]
  # @return [Hash]
  def self.retrieve_manifest(url)
    manifest_response = Faraday.get(url)
    JSON.parse(manifest_response.body)
  rescue Faraday::ConnectionFailed => connection_error
    Rails.logger.error connection_error
    {}
  rescue JSON::ParserError => json_error
    Rails.logger.error json_error
    {}
  end

  # Retrieve the URL for a retrieved manifest
  # If the manifest is a collection, retrieve the first child node
  # @param manifest [Hash]
  # @return [String]
  def self.find_manifest_root_node(manifest)
    return manifest unless manifest['@type'] == 'sc:Collection'

    children = manifest['manifests']
    child_manifests = []
    children.each do |child_uri|
      child_manifest = retrieve_manifest(child_uri)
      child_manifests << find_manifest_root_node(child_manifest)
    end
    child_manifests.first
  end

  after_initialize do
    # Initialize the private instance variable for caching manifests
    @cached_manifests = {}
  end

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
    return @manifests unless @manifests.nil?

    @manifests = []
    versions.map do |version|
      manifest = retrieve_manifest(version.manifest)
      manifest_root_node = self.class.find_manifest_root_node(manifest)
      @manifests << manifest_root_node['@id']
    end
    @manifests
  end

  def range_labels_from_manifests
    manifests.map do |url|
      manifest = retrieve_manifest(url)
      manifest['structures'].map { |s| s['label'] } if manifest['structures']
    end.flatten
  end

  def digitized_version_available
    return ['None'] if versions.empty?
    versions.map { |v| v.based_on_original? ? 'Microfiche' : 'Matching copy' }
  end

  private

  # Retrieves and cached a manifest from a URL
  # @param url [String]
  def retrieve_manifest(url)
    @cached_manifests[url] || @cached_manifests[url] = self.class.retrieve_manifest(url)
  end
end
