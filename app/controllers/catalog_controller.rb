# frozen_string_literal: true
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    # config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1
    #  # q: '{!term f=id v=$id}'
    # }

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'
    config.index.partials = [:item_partial, :index_links]
    config.show.partials = [:show_header, :show_browse, :linked_books, :comments]
    config.show.partials.insert(1, :universal_viewer)
    config.show.document_actions.replace({})

    # solr field configuration for document/show views
    # config.show.title_field = 'title_display'
    # config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'name_facet', label: 'Name', limit: true
    config.add_facet_field 'pub_date', label: 'Publication Year', single: true, limit: true
    config.add_facet_field 'subject_era_facet', label: 'Era', limit: true
    config.add_facet_field 'language_facet', label: 'Language', limit: true
    config.add_facet_field 'subject_geo_facet', label: 'Region', limit: true
    config.add_facet_field 'subject_genre_facet', label: 'Genre', limit: true
    config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: true, index_range: 'A'..'Z'
    config.add_facet_field 'subject_facet', label: 'Subject', show: false
    config.add_facet_field 'tei_section_facet', label: 'Catalogo Section', limit: true
    config.add_facet_field 'contributing_library_facet', label: 'Contributing Library', limit: true
    config.add_facet_field 'digitized_version_available_facet', label: 'Digitized Version Available', limit: true

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'tei_title_txt', label: 'Title(s)'
    config.add_index_field 'tei_author_txt', label: 'Author(s)'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'tei_title_txt', label: 'Title(s)'
    config.add_show_field 'tei_author_txt', label: 'Author(s)'
    config.add_show_field 'tei_pub_txt', label: 'Publication place(s)'
    config.add_show_field 'tei_date_display', label: 'Publication date(s)'
    config.add_show_field 'tei_section_head_italian', label: 'Section head'
    config.add_show_field 'tei_note_italian', label: 'Note(s)'
    config.add_show_field 'title_addl_display', label: 'Other title(s)', separator_options: { words_connector: '<br/>', two_words_connector: '<br/>', last_word_connector: '<br/>' }
    config.add_show_field 'edition_display', label: 'Edition'
    config.add_show_field 'author_display', label: 'Author', link_to_search: :name_facet
    config.add_show_field 'published_display', label: 'Imprint'
    config.add_show_field 'contents_display', label: 'Contents'
    config.add_show_field 'language_display', label: 'Language'
    config.add_show_field 'cico_id_display', label: 'Cicognara number'
    config.add_show_field 'note_display', label: 'Note(s)', separator_options: { words_connector: '<br/>', two_words_connector: '<br/>', last_word_connector: '<br/>' }
    config.add_show_field 'title_added_entry_display', label: 'Added entry title(s)'
    config.add_show_field 'related_name_display', label: 'Related name(s)', link_to_search: :name_facet
    config.add_show_field 'subject_t', label: 'Subject', link_to_search: :subject_facet
    config.add_show_field 'place_display', label: 'Place of publications'
    config.add_show_field 'description_display', label: 'Description'
    config.add_show_field 'title_series_display', label: 'Series'
    config.add_show_field 'dclib_display', label: 'DCL number'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        qf: '$title_qf',
        pf: '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        qf: '$author_qf',
        pf: '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = {
        qf: '$subject_qf',
        pf: '$subject_pf'
      }
    end

    config.add_search_field('catalogo') do |field|
      field.label = 'Catalogo Nr'
      field.solr_local_parameters = { qf: 'id' }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'cico_sort asc', label: 'catalogo nr'
    config.add_sort_field 'pub_date_sort asc, title_sort asc', label: 'year (oldest first)'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'year (newest first)'
    config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
    config.add_sort_field 'title_sort asc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end

  def show
    super
    @linked_books = @document.fetch('dclib_s', []).map do |dcn|
      begin
        fetch_one(dcn, {}).last
      rescue
        nil
      end
    end
    @linked_books.compact!
    @linked_books.uniq!(&:_source) if @linked_books.length > 1
    @comments = Comment.where(entry_id: params[:id])
  rescue Blacklight::Exceptions::RecordNotFound
    render 'errors/not_found', status: 404
  end

  def has_search_parameters?
    true
  end
end
