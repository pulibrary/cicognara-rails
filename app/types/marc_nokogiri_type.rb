# frozen_string_literal: true
class MarcNokogiriType < NokogiriType
  def cast(value)
    result = super
    return result if result.blank? || result.root.blank? || result.root.namespaces.present?
    result.root['xmlns'] = 'http://www.loc.gov/MARC21/slim'
    result
  end
end
