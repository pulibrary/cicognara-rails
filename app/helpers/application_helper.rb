module ApplicationHelper
  def catalogo_link(document)
    item = document['id']
    section = document['tei_section_number_display'].first
    link_to(document['title_display'], page_path("catalogo/section_#{section}", anchor: "item_#{item}"))
  end
end
