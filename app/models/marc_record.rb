
class MarcRecord < ApplicationRecord
  belongs_to :book
  attribute :source, :marc_nokogiri_type

  def self.resolve(file_uri)
    # Search for the MARC record
    # Retrieve the file path from the URI
    file_path_m = %r{file\:\/\/(.+?)(\/\/.+?)\[(\d+)\]}.match(file_uri)
    # binding.pry
    raise StandardError, "Failed to extract the file path from #{file_uri}" unless file_path_m

    file_path = file_path_m[1]
    marc_xpath = file_path_m[2]
    marc_record_index = file_path_m[3].to_i
    raise StandardError, "File path does not exist: #{file_path}" unless File.exist?(file_path)

    marc_record_document = File.open(file_path) { |f| Nokogiri::XML(f) }
    marc_record_elements = marc_record_document.xpath(marc_xpath, marc: 'http://www.loc.gov/MARC21/slim')
    marc_record_element = marc_record_elements[marc_record_index]
    raise StandardError, "Failed to resolve XPath: #{marc_xpath} using the index #{marc_record_index}" unless marc_record_element

    marc_record = where(file_uri: file_uri).first_or_create do |created_marc_record|
      created_marc_record.source = marc_record_element
    end

    marc_record
  end

  # Retrieve the Digital Cicognara Library numbers from the MARC-XML
  # @return [Array<String>]
  def digital_cico_numbers
    source.xpath('/marc:record/marc:datafield[@tag=024]/marc:subfield[@code="a" and ../marc:subfield="dclib"]', marc: 'http://www.loc.gov/MARC21/slim').map(&:text)
  end

  # Retrieve the first Digital Cicognara Library number from the MARC-XML
  # @return [String]
  def primary_digital_cico_number
    digital_cico_numbers.first
  end
  alias book_id primary_digital_cico_number
end
