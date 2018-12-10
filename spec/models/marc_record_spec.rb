# frozen_string_literal: true

require 'rails_helper'

describe MarcRecord, type: :model do
  subject(:marc_record) { described_class.resolve("file://#{file_path}//marc:record[0]") }

  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }

  describe '.resolve' do
    it 'constructs MarcRecord objects for MARC record XPaths' do
      expect(marc_record).to be_a MarcRecord
      expect(marc_record.source).to be_a Nokogiri::XML::Document
    end

    context 'when the file URI is invalid' do
      it 'raises an error' do
        expect { described_class.resolve("invalid://#{file_path}//marc:record[0]") }.to raise_error(StandardError, "Failed to extract the file path from invalid://#{file_path}//marc:record[0]")
      end
    end

    context 'when the file does not exist' do
      it 'raises an error' do
        expect { described_class.resolve("file://#{file_path}/noexist//marc:record[0]") }.to raise_error(StandardError, "File path does not exist: #{file_path}/noexist")
      end
    end

    context 'when the XPath is valid but does not resolve' do
      it 'raises an error' do
        expect { described_class.resolve("file://#{file_path}//marc:record[99]") }.to raise_error(StandardError, 'Failed to resolve XPath: //marc:record using the index 99')
      end
    end
  end

  describe '#digital_cico_numbers' do
    it 'retrieves the MARC element text content containing the Digital Cicognara Library numbers' do
      expect(marc_record.digital_cico_numbers).to be_an Array
      expect(marc_record.digital_cico_numbers).not_to be_empty
      expect(marc_record.digital_cico_numbers.first).to eq 'cico:m87'
    end
  end

  describe '#primary_digital_cico_number' do
    it 'retrieves the text content from the first MARC element containing a Digital Cicognara Library number' do
      expect(marc_record.primary_digital_cico_number).to eq 'cico:m87'
    end
  end

  describe '#book_id' do
    it 'aliases #primary_digital_cico_number' do
      expect(marc_record.book_id).to eq 'cico:m87'
      expect(marc_record.book_id).to eq marc_record.primary_digital_cico_number
    end
  end
end
