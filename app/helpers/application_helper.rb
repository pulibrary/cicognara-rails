module ApplicationHelper
  def catalogo_link(document)
    item = document['id']
    section = document['tei_section_number_display'].first
    static_page_path("catalogo/section_#{section}", anchor: "item_#{item}")
  end

  def current_year
    DateTime.current.year
  end

  def ul(args)
    value = args[:document][args[:field]]
    if value.length == 1
      value.first
    else
      content_tag(:ul, safe_join(value.map { |v| content_tag(:li, v) }))
    end
  end

  def html_safe(args)
    args[:document][args[:field]].map!(&:html_safe)
    ul(args)
  end

  # Generate the URL for the search form
  # @param options [Hash]
  # @return [String]
  def search_form_action_url(options = {})
    return url_for(options.merge(action: 'index', controller: 'catalog')) if controller_name == 'advanced'

    search_action_url(options)
  end
end
