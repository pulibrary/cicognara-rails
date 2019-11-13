# frozen_string_literal: true

# This doesn't do much yet but in the next step it will
# stick version metadata into a solr document
module ShowHelper
  def version_show_document
    SolrDocument.new('format' => 'idk')
  end
end
