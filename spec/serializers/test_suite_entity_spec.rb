# frozen_string_literal: true

require 'spec_helper'

describe TestSuiteEntity do
  let(:pipeline) { create(:ci_pipeline, :with_test_reports) }
  let(:entity) { described_class.new(pipeline.test_reports.test_suites.each_value.first) }

  describe '#as_json' do
    subject(:as_json) { entity.as_json }

    it 'contains the suite name' do
      expect(as_json).to include(:name)
    end

    it 'contains the total time' do
      expect(as_json).to include(:total_time)
    end

    it 'contains the counts' do
      expect(as_json).to include(:total_count, :success_count, :failed_count, :skipped_count, :error_count)
    end

    it 'contains the test cases' do
      expect(as_json).to include(:test_cases)
      expect(as_json[:test_cases].count).to eq(4)
    end

    it 'contains an empty error message' do
      expect(as_json[:suite_error]).to be_nil
    end

    context 'with malformed junit xml' do
      let(:pipeline) { create(:ci_pipeline, :with_test_reports, :with_broken_test_reports) }

      it 'contains the suite name' do
        expect(as_json[:name]).to be_present
      end

      it 'contains the total time' do
        expect(as_json[:total_time]).to be_present
      end

      it 'returns all the counts as 0' do
        expect(as_json[:total_count]).to eq(0)
        expect(as_json[:success_count]).to eq(0)
        expect(as_json[:failed_count]).to eq(0)
        expect(as_json[:skipped_count]).to eq(0)
        expect(as_json[:error_count]).to eq(0)
      end

      it 'returns no test cases' do
        expect(as_json[:test_cases]).to be_empty
      end

      it 'returns a suite error' do
        expect(as_json[:suite_error]).to eq('Syntax error: Failed to parse JUnit XML data')
      end
    end
  end
end
