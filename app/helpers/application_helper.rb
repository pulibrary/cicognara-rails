module ApplicationHelper
  def catalogo_link(document)
    item = document['id']
    section = document['tei_section_number_display'].first
    static_page_path("catalogo/section_#{section}", anchor: "item_#{item}")
  end

  def current_year
    DateTime.current.year
  end

  def layout(manifests)
    if manifests.length < 2
      '1x1'
    elsif manifests.length == 2
      '1x2'
    else
      "#{manifests.length / 2}x2"
    end
  end
end
