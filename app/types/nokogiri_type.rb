# frozen_string_literal: true
class NokogiriType < ActiveRecord::Type::Value
  def cast(value)
    Nokogiri::XML(value.to_s)
  end

  def serialize(value)
    value.to_xml
  end
end
