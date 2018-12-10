# frozen_string_literal: true
class MarcNokogiriType < NokogiriType
  def cast(value)
    result = super
    return result if result.blank? || result.root.blank?
    result.root.default_namespace = 'http://www.loc.gov/MARC21/slim'
    result
  end

  def serialize(value)
    return value if value.blank? || value.root.blank?
    value.root.default_namespace = 'http://www.loc.gov/MARC21/slim'
    value.to_xml
  end
end
