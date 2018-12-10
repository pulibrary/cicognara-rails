# coding: utf-8
require 'rails_helper'

class TestWriter
  attr_reader :settings

  def self.accumulator=(acc)
    @acc = acc
  end

  def self.accumulator
    @acc
  end

  def initialize(accumulator)
    @acc = accumulator
  end

  def close
  end

  def put(context)
    @acc << context.output_hash
  end

  def serialize(context)
  end
end

RSpec.describe MarcIndexer, type: :model do
  subject(:marc_indexer) do
    indexer = described_class.new
    indexer.writer = writer
    indexer
  end

  let(:writer) { TestWriter.new(@values) }
  let(:marc_file) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:file_uri) { 'file://dir/file.mrx//marc:record[0]' }
  let(:file_uri_digest) { Digest::MD5.hexdigest(file_uri) }

  before(:all) do
    @values = []
  end

  before do
    marc_indexer.process(marc_file, file_uri)
  end

  it 'indexes marc for display' do
    expect(@values.first['marc_display']).not_to be nil
  end

  it 'indexes 024$a values using the dclib_display field' do
    expect(@values.first['dclib_display']).to eq(['cico:m87'])
  end

  it 'indexes title' do
    expect(@values.first['title_t']).to eq(['Henrici Cornelii Agrippae ab Nettesheym De incertitudine et vanitate scientiarum declamatio inuestiua [microform] / ex postrema authoris recognitione.'])
  end
  it 'indexes the ID using the file URI' do
    expect(@values.first['id']).to eq(file_uri_digest)
  end
  it 'indexes the file_uri_s using the file URI' do
    expect(@values.first['file_uri_s']).to eq(file_uri)
  end
  it 'indexes additional titles' do
    expect(@values.first['title_addl_t']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
  end
  it 'converts language code to label in language_facet' do
    expect(@values.first['language_facet']).to eq(['Latin'])
  end
  it 'adds field subject_t field combining topic/genre/era' do
    expect(@values.first['subject_t']).to include('Learning and scholarship—Early works to 1800')
    expect(@values.first['subject_t']).to include('Medicine—Early works to 1800')
    expect(@values.first['subject_t']).to include('Medicine—History—16th century')
    expect(@values.first['subject_t']).to include('Science—Early works to 1800')
  end
  it 'indexes subject_topic_facet' do
    expect(@values.first['subject_topic_facet']).to include('Learning and scholarship')
    expect(@values.first['subject_topic_facet']).to include('Medicine')
    expect(@values.first['subject_topic_facet']).to include('History')
    expect(@values.first['subject_topic_facet']).to include('Science')
  end
  it 'indexes subject_genre_facet' do
    expect(@values.first['subject_genre_facet']).to include('Early works to 1800')
  end
  it 'indexes subject_era_facet' do
    expect(@values.first['subject_era_facet']).to eq(['16th century'])
  end
  it 'indexes field published_t' do
    expect(@values.first['published_t']).to eq(['Coloniae : Apud Theodorum Baumium ..., Anno 1584.'])
  end
  it 'takes pub_date from 008' do
    expect(@values.first['pub_date']).to eq([1584])
  end
  it 'does not have the term microform in the 245 field' do
    expect(@values.first['title_display'].first).not_to match(/microform/)
  end
  it 'does not have Fondo Cicognara or Leopoldo Cicognara Program in author_t' do
    expect(@values.first['author_t']).not_to include(match(/Fondo Cicognara/))
    expect(@values.first['author_t']).not_to include(match(/Leopoldo Cicognara Program/))
  end
  it 'does not have Fondo Cicognara or Leopoldo Cicognara Program in name_facet' do
    expect(@values.first['name_facet']).not_to include(match(/Fondo Cicognara/))
    expect(@values.first['name_facet']).not_to include(match(/Leopoldo Cicognara Program/))
  end
  it 'does not have Fondo Cicognara or Leopoldo Cicognara Program in related_name_display, excludes uri' do
    expect(@values.first['related_name_display']).to be nil
    expect(@values[2]['related_name_display'].first).to eq 'Bogus place'
  end
  it 'indexes Cicognara numbers from the 510 field' do
    expect(@values[4]['cico_id_display']).to eq(%w[4716 4025])
  end
  it 'indexes note labels' do
    expect(@values[4]['note_display']).to include('<strong>Fiche no.:</strong> 4716=4025.')
  end
  it 'indexes hierarchical places' do
    expect(@values[4]['place_display']).to eq(['Germany—Bremen'])
  end
end
