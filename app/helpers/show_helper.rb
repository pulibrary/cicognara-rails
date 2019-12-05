# frozen_string_literal: true

# stick version metadata into a solr document
module ShowHelper
  def version_show_document(version)
    metadata = version.imported_metadata || {}
    SolrDocument.new(metadata.merge(blacklight_required_fields))
  end

  def blacklight_required_fields
    { 'format' => 'dummy_value' }
  end
end
