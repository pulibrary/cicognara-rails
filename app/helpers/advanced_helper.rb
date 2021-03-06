# frozen_string_literal: true

# Helper methods for the advanced search form
module AdvancedHelper
  include BlacklightAdvancedSearch::AdvancedHelperBehavior

  # Fill in default from existing search, if present
  # -- if you are using same search fields for basic
  # search and advanced, will even fill in properly if existing
  # search used basic search on same field present in advanced.
  def label_tag_default_for(key)
    if params[key].present?
      params[key]
    elsif params['search_field'] == key || guided_context(key)
      params['q']
    end
  end

  def advanced_key_value
    key_value = []
    search_fields_for_advanced_search.each do |field|
      key_value << [field[1][:label], field[0]]
    end
    key_value
  end

  # carries over original search field and original guided search fields if user switches to guided search from regular search
  def guided_field(field_num, default_val)
    return search_fields_for_advanced_search[params[:search_field]].key || default_val if switched_to_guided_search?(field_num)

    params[field_num] || default_val
  end

  def switched_to_guided_search?(field_num)
    field_num == :f1 && params[:f1].nil? && params[:f2].nil? && params[:f3].nil? && params[:search_field] && search_fields_for_advanced_search[params[:search_field]]
  end

  # carries over guided search operations if user switches back to guided search from regular search
  def guided_radio(op_num, operation)
    if params[op_num]
      params[op_num] == operation
    else
      operation == 'AND'
    end
  end

  # This overrides a method featured upstream
  # @see Blacklight::AdvancedHelper#generate_solr_fq
  # @return [Array<String>]
  def generate_solr_fq
    filters.map do |solr_field, value_list|
      value_list = value_list.values if value_list.is_a?(Hash)

      "#{solr_field}:(" +
        Array(value_list).collect { |v| '"' + v.gsub('"', '\"') + '"' }.join(' OR  ') +
        ')'
    end
  end

  private

  # carries over original search query if user switches to guided search from regular search
  def guided_context(key)
    key == :q1 && params[:f1].nil? && params[:f2].nil? && params[:f3].nil? &&
      params[:search_field] && search_fields_for_advanced_search[params[:search_field]]
  end
end

module BlacklightAdvancedSearch
  class QueryParser
    include AdvancedHelper
    def keyword_op
      # for guided search add the operations if there are queries to join
      # NOTs get added to the query. Only AND/OR are operations
      @keyword_op = []
      unless @params[:q1].blank? || @params[:q2].blank? || @params[:op2] == 'NOT'
        @keyword_op << @params[:op2] if @params[:f1] != @params[:f2]
      end
      unless @params[:q3].blank? || @params[:op3] == 'NOT' || (@params[:q1].blank? && @params[:q2].blank?)
        @keyword_op << @params[:op3] unless [@params[:f1], @params[:f2]].include?(@params[:f3]) && ((@params[:f1] == @params[:f3] && @params[:q1].present?) || (@params[:f2] == @params[:f3] && @params[:q2].present?))
      end
      @keyword_op
    end

    def keyword_queries
      unless @keyword_queries
        @keyword_queries = {}

        return @keyword_queries unless @params[:search_field] == ::AdvancedController.blacklight_config.advanced_search[:url_key]

        # Spaces need to be stripped from the query because they don't get properly stripped in Solr
        q1 = odd_quotes(@params[:q1])
        params[:q1] = q1
        q2 = odd_quotes(@params[:q2])
        params[:q2] = q2
        q3 = odd_quotes(@params[:q3])
        params[:q3] = q3

        been_combined = false
        @keyword_queries[@params[:f1]] = q1 if @params[:q1].present?
        if @params[:q2].present?
          if @keyword_queries.key?(@params[:f2])
            @keyword_queries[@params[:f2]] = "(#{@keyword_queries[@params[:f2]]}) " + @params[:op2] + " (#{q2})"
            been_combined = true
          elsif @params[:op2] == 'NOT'
            @keyword_queries[@params[:f2]] = 'NOT ' + q2
          else
            @keyword_queries[@params[:f2]] = q2
          end
        end
        if @params[:q3].present?
          if @keyword_queries.key?(@params[:f3])
            @keyword_queries[@params[:f3]] = "(#{@keyword_queries[@params[:f3]]})" unless been_combined
            @keyword_queries[@params[:f3]] = "#{@keyword_queries[@params[:f3]]} " + @params[:op3] + " (#{q3})"
          elsif @params[:op3] == 'NOT'
            @keyword_queries[@params[:f3]] = 'NOT ' + q3
          else
            @keyword_queries[@params[:f3]] = q3
          end
        end
      end

      @keyword_queries
    end

    private

    # Remove stray quotation mark if there are an odd number of them
    # @param query [String] the query
    # @return [String] the query with an even number of quotation marks
    def odd_quotes(query)
      if query&.count('"')&.odd?
        query.sub(/"/, '')
      else
        query
      end
    end
  end
end

module BlacklightAdvancedSearch
  module ParsingNestingParser
    # Iterates through the keyword queries and appends each operator the extracting queries
    # @param [ActiveSupport::HashWithIndifferentAccess] _params
    # @param [Blacklight::Configuration] config
    # @return [Array<String>]
    def process_query(_params, config)
      if config.advanced_search.nil?
        Blacklight.logger.error "Failed to parse the advanced search, config. settings are not accessible for: #{config}"
        return []
      end

      queries = []
      ops = keyword_op
      keyword_queries.each do |field, query|
        query_parser_config = config.advanced_search[:query_parser]
        begin
          parsed = ParsingNesting::Tree.parse(query, query_parser_config)
        rescue Parslet::ParseFailed => parse_failure
          Blacklight.logger.warn "Failed to parse the query: #{query}: #{parse_failure}"
          next
        end

        # Test if the field is valid
        next unless config.search_fields[field]

        local_param = local_param_hash(field, config)
        queries << parsed.to_query(local_param)
        queries << ops.shift
      end
      queries.join(' ')
    end
  end
end

module BlacklightAdvancedSearch
  module CatalogHelperOverride
    def remove_guided_keyword_query(fields, my_params = params)
      my_params = Blacklight::SearchState.new(my_params, blacklight_config).to_h
      fields.each do |guided_field|
        my_params.delete(guided_field)
      end
      my_params
    end
  end
end

module BlacklightAdvancedSearch
  module RenderConstraintsOverride
    def guided_search(my_params = params)
      constraints = []
      if my_params[:q1].present? && my_params[:f1].present?
        label = search_field_def_for_key(my_params[:f1]).try(:label)
        if label
          query = my_params[:q1]
          constraints << render_constraint_element(
            label, query,
            remove: search_catalog_path(remove_guided_keyword_query([:f1, :q1], my_params))
          )
        end
      end
      if my_params[:q2].present? && my_params[:f2].present?
        label = search_field_def_for_key(my_params[:f2]).try(:label)
        if label
          query = my_params[:q2]
          query = 'NOT ' + my_params[:q2] if my_params[:op2] == 'NOT'
          constraints << render_constraint_element(
            label, query,
            remove: search_catalog_path(remove_guided_keyword_query([:f2, :q2, :op2], my_params))
          )
        end
      end
      if my_params[:q3].present? && my_params[:f3].present?
        label = search_field_def_for_key(my_params[:f3]).try(:label)
        if label
          query = my_params[:q3]
          query = 'NOT ' + my_params[:q3] if my_params[:op3] == 'NOT'
          constraints << render_constraint_element(
            label, query,
            remove: search_catalog_path(remove_guided_keyword_query([:f3, :q3, :op3], my_params))
          )
        end
      end
      constraints
    end

    # Over-ride of Blacklight method, provide advanced constraints if needed,
    # otherwise call super.
    def render_constraints_query(my_params = params)
      if advanced_query.nil? || advanced_query.keyword_queries.empty?
        super(my_params)
      else
        content = guided_search
        safe_join(content.flatten, "\n")
      end
    end
  end
end
