# frozen_string_literal: true

# stick version metadata into a solr document
module ShowHelper
  # Handles the rendering of related_names in the Show page
  # rubocop:disable Rails/OutputSafety
  def related_name_display_helper(data)
    document = data[:document]

    if document['related_name_display_from_version']
      # Related names from the Version information are not indexed
      # so we just display them as text.
      return document['related_name_display'].join(', ')
    end

    # Related names from the Book information are indexed and
    # therefore we render them as search links.
    links = document['related_name_display'].map do |value|
      url = "#{search_catalog_url}?f[name_facet][]=#{value}"
      link_to(value, url)
    end
    links.join(', ').html_safe
  end
  # rubocop:enable Rails/OutputSafety

  # Creates a SolrDocument object out of a Version ActiveRecord object.
  # rubocop:disable Metrics/MethodLength
  def version_show_document(version, book_doc = nil)
    metadata = version.imported_metadata || {}
    version_doc = SolrDocument.new(metadata.merge(blacklight_required_fields))

    if book_doc['subject_topic_facet']
      # Take the "subject_topic_facet" info from the book document since
      # the version document only has the "subject_t" field that is not
      # suitable for faceting,
      version_doc['subject_topic_facet'] = book_doc['subject_topic_facet']
    end

    if book_doc['related_name_display']
      # Prefer the information on the book since it is indexed
      version_doc['related_name_display'] = book_doc['related_name_display']
    elsif version_doc['related_name_display']
      # Flag that we are using the information from the version
      version_doc['related_name_display_from_version'] = true
    end

    version_doc
  end
  # rubocop:enable Metrics/MethodLength

  def blacklight_required_fields
    { 'format' => 'dummy_value' }
  end
end
