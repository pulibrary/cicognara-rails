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
  let(:values) { [] }
  let(:marc_file) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:writer) { TestWriter.new(values) }
  subject { described_class.new }

  before do
    subject.writer = writer
    subject.process(marc_file)
  end

  it 'indexes marc for display' do
    expect(values.first['marc_display']).not_to be nil
  end

  it 'indexes format' do
    expect(values.first['format']).to eq(['Microfilm'])
  end

  it 'indexes title' do
    expect(values.first['title_display']).to eq(['Henrici Cornelii Agrippae ab Nettesheym De incertitudine et vanitate scientiarum declamatio inuestiua'])
  end
end
