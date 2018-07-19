require 'csv'

namespace :csv do
  desc 'import data from csv file'
  task import: :environment do
    abort 'usage: rake csv:import /path/to/csv/file' unless ARGV[1] && File.exist?(ARGV[1])
    logger = Logger.new(STDOUT)

    row_index = 1
    CSV.foreach(ARGV[1], headers: true) do |row|
      begin
        contrib = ContributingLibrary.where(label: row['contributing_library']).first
        unless contrib
          logger.warn "Unable to find contributing library: #{row['contributing_library']}"
          next
        end
        existing = Version.where(owner_system_number: row['owner_system_number'], contributing_library: contrib).first
        if existing
          existing.attributes = Cicognara::CSVMapper.map(row.to_h, row_index)
          existing.save
          logger.info "Updated version #{existing.id} #{row['digital_cico_number']} #{row['label']}"
          next
        end
        v = Version.create Cicognara::CSVMapper.map(row.to_h, row_index)
        logger.info "Created version #{v.id} #{row['digital_cico_number']} #{row['label']}"
      rescue ArgumentError => e
        logger.warn e.to_s
      end

      row += 1
    end
  end
end
