# frozen_string_literal: true
class Entry < ApplicationRecord
  has_many :books

  attribute :tei, :tei_type
  before_save :assign_n_value

  def to_solr
    catalogo_item.solr_doc
  end

  def catalogo_item
    @catalogo_item ||= Cicognara::CatalogoItem.new(self)
  end

  def n
    # binding.pry
    ns = tei.xpath('./@n')
    ns.empty? ? 'NO_N' : ns.first.value
  end

  # Extracts identifiers referring to the bibliographic sources
  # i. e. references to what are modeled as Books
  # @return [Array<String>] the identifiers
  def corresp
    c = tei.xpath('./@corresp')
    c.empty? ? [] : c.first.value.split
  end

  def item_label
    title = tei.xpath('./label')
    NormalizedString.new(title.first).value
  end

  def item_titles
    titles = tei.xpath('./bibl/title')
    NormalizedString.new(titles).array_value
  end

  def item_authors
    authors = tei.xpath('./bibl/author')
    NormalizedString.new(authors).array_value
  end

  def item_pubs
    pubs = tei.xpath('./bibl/pubPlace')
    NormalizedString.new(pubs).array_value
  end

  def item_dates
    dates = tei.xpath('.//date')
    NormalizedString.new(dates).array_value
  end

  def item_notes
    notes = tei.xpath('./note')
    NormalizedString.new(notes).array_value
  end

  def text
    NormalizedString.new(tei).value
  end

  class NormalizedString
    attr_reader :string
    def initialize(string)
      @string = string
    end

    def value
      return nil unless string.respond_to?(:text)
      string.text.gsub(/\s+/, ' ').strip
    end

    def array_value
      string.map do |x|
        NormalizedString.new(x).value
      end
    end
  end

  private

  def assign_n_value
    # binding.pry
    self.n_value = n
  end
end
