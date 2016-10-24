# frozen_string_literal: true
class TeiType < ActiveRecord::Type::Value
  def cast(value)
    Nokogiri::XML(value.to_s).xpath('./item')
  end

  def serialize(value)
    value.to_s
  end
end
