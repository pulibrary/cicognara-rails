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
  before(:all) do
    @values = []
    marc_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    subject = described_class.new
    subject.writer = TestWriter.new(@values)
    subject.process(marc_file)
  end

  it 'indexes marc for display' do
    expect(@values.first['marc_display']).not_to be nil
  end

  it 'indexes title' do
    expect(@values.first['title_t']).to eq(['Henrici Cornelii Agrippae ab Nettesheym De incertitudine et vanitate scientiarum declamatio inuestiua [microform] / ex postrema authoris recognitione.'])
  end
  it 'takes id from dclib in 024' do
    expect(@values.first['id']).to eq(['cico:m87'])
  end
  it 'indexes additional titles' do
    expect(@values.first['title_addl_t']).to include 'Henrici Cornelii Agrippae ab Nettesheym De incertitudine et vanitate scientiarum declamatio inuestiua'
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
  after(:all) { Book.destroy_all }
end
