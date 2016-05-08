# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  self.default_processor_chain += [:remove_marc]

  def remove_marc(solr_params)
    solr_params[:fq] << '-{!raw f=format}marc'
  end
end
