module ApplicationHelper
  def catalogo_link(document)
    item = document['id']
    section = document['tei_section_number_display'].first
    static_page_path("catalogo/section_#{section}", anchor: "item_#{item}")
  end

  def current_year
    DateTime.current.year
  end

  def html_safe(args)
    args[:document][args[:field]].join('<br/>').html_safe
  end
end
