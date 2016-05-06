module ApplicationHelper
  def render_html(args)
    args[:document][args[:field]].each_with_index do |value, i|
      args[:document][args[:field]][i] = value.html_safe
    end
  end
end
