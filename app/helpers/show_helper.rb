# frozen_string_literal: true

# stick version metadata into a solr document
module ShowHelper
  # Creates a SolrDocument object out of a Version ActiveRecord object.
  def version_show_document(version, book_doc = nil)
    metadata = version.imported_metadata || {}
    version_doc = SolrDocument.new(metadata.merge(blacklight_required_fields))
    if book_doc['subject_topic_facet']
      # Take the "subject_topic_facet" info from the book document since
      # the version document only has the "subject_t" field that is not
      # suitable for faceting,
      version_doc['subject_topic_facet'] = book_doc['subject_topic_facet']
    end
    version_doc
  end

  def blacklight_required_fields
    { 'format' => 'dummy_value' }
  end
end
