# frozen_string_literal: true

require 'rails_helper'

describe AdvancedHelper do
  describe '#process_query' do
    subject(:test_helper) { TestHelper.new }

    let(:_params) { ActiveSupport::HashWithIndifferentAccess.new({}) }
    # Blacklight::Configuration behaves like an OpenStruct for #advanced_search
    let(:config) { double }

    before do
      class TestHelper
        include BlacklightAdvancedSearch::ParsingNestingParser

        def keyword_op; end

        def keyword_queries
          { test_field: 'test_query' }
        end
      end

      allow(config).to receive(:advanced_search)
    end

    after do
      Object.send(:remove_const, :TestHelper)
    end

    context 'when the advanced search config. settings are not accessible' do
      before do
        allow(Blacklight.logger).to receive(:error)

        test_helper.process_query(_params, config)
      end
      it 'logs an error' do
        expect(Blacklight.logger).to have_received(:error).with(/Failed to parse the advanced search, config. settings are not accessible for: /)
      end
    end

    context 'when the parsing fails for a query' do
      before do
        allow(config).to receive(:advanced_search).and_return(query_parser: nil)
        allow(ParsingNesting::Tree).to receive(:parse).and_raise(Parslet::ParseFailed, 'test failure')
        allow(Blacklight.logger).to receive(:warn)

        test_helper.process_query(_params, config)
      end

      it 'logs a warning' do
        expect(Blacklight.logger).to have_received(:warn).with('Failed to parse the query: test_query: test failure')
      end
    end
  end
end
