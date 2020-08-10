class GettyParser
  attr_reader :resource_dump_url
  def initialize(resource_dump_url: 'http://portal.getty.edu/resources/json_data/resourcedump.xml')
    @resource_dump_url = resource_dump_url
  end

  def urls
    @urls ||= UrlSet.from(parsed_xml)
  end

  def records
    @records ||=
      begin
        records = []
        download_and_read_each do |record|
          next unless record.cicognara? && record.dcl_number.present?
          next if record.manifest_url.blank?

          records << record
        end
        records
      end
  end

  def import!
    Importer.new(records: records).import!
  end

  def download_and_read_each
    urls.latest.each do |url|
      file = download(url.url)
      Zip::File.open(file) do |zip_file|
        zip_file.each do |entry|
          next unless entry.name.include?('json')

          record = GettyRecord.from(JSON.parse(entry.get_input_stream.read))
          yield record
        end
      end
    end
  end

  private

  def download(url)
    output_path = Rails.root.join('tmp', Pathname.new(url).basename)
    unless File.exist?(output_path)
      Rails.logger.info "Downloading #{url}.."
      Down.download(url, destination: output_path)
      Rails.logger.info "Downloaded #{url}"
    end
    File.open(output_path)
  end

  def output
    @output ||= open(resource_dump_url)
  end

  def parsed_xml
    @parsed_xml ||=
      begin
        doc = Nokogiri::XML.parse(output)
        doc.remove_namespaces!
        doc
      end
  end

  class UrlSet
    def self.from(parsed_xml)
      urls = parsed_xml.xpath('//urlset/url').map { |x| URL.from(x) }.sort_by(&:at)
      urls = urls.group_by do |url|
        url.url.rpartition('-').first
      end
      new(urls: urls)
    end

    attr_reader :urls
    def initialize(urls:)
      @urls = urls
    end

    def latest
      all_urls = urls.to_a.last[1]
      latest_index = all_urls.rindex { |x| x.url.include?('part1') }
      all_urls[latest_index..-1]
    end
  end

  class URL
    def self.from(xml)
      new(
        url: xml.xpath('./loc').first.text,
        at: Time.zone.parse(xml.xpath('./md').first.attributes['at'].value)
      )
    end

    attr_reader :url, :at
    def initialize(url:, at:)
      @url = url
      @at = at
    end
  end
end
