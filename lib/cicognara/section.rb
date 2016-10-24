module Cicognara
  class Section
    attr_reader :section
    def initialize(section)
      @section = section
    end

    def section_number
      section.xpath('@n').first.value
    end

    def section_head
      section.xpath('tei:head', tei: 'http://www.tei-c.org/ns/1.0').first.text
    end

    def section_display
      section.xpath("tei:head/tei:seg[@type='main']", tei: 'http://www.tei-c.org/ns/1.0').first.text
    end

    def items
      section.xpath(".//tei:list[@type='catalog']/tei:item", tei: 'http://www.tei-c.org/ns/1.0')
    end
  end
end
