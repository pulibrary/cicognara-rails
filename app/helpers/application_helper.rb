module ApplicationHelper
  def catalogo_link(document)
    item = document['id']
    section = document['section_s'].first
    link_to(document['title_display'], "/catalogo/section_#{section}/index.html#item_#{item}")
  end
end
