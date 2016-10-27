module Cicognara
  class MarcRecord
    attr_reader :source
    def initialize(source)
      @source = source
    end

    def book_id
      source.xpath('./marc:datafield[@tag=024]/marc:subfield[@code="a" and ../marc:subfield="dclib"]', marc: 'http://www.loc.gov/MARC21/slim').map(&:text).first
    end
  end
end
