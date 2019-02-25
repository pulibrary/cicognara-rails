# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  self.default_processor_chain += [:remove_marc]

  def remove_marc(solr_params)
    solr_params[:fq] << '-{!raw f=format}marc'
  end
end
