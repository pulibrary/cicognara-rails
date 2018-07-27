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
end
