# frozen_string_literal: true

require 'spec_helper'

describe TestReportSummaryEntity do
  let(:build_1) { create(:ci_build, :report_results) }
  let(:build_2) { create(:ci_build, :report_results) }
  let(:report_results) { build_1.report_results + build_2.report_results }
  let(:test_report_summary) { Gitlab::Ci::Reports::TestReportSummary.new(report_results) }
  let(:entity) { described_class.new(test_report_summary) }

  describe '#as_json' do
    subject(:as_json) { entity.as_json }

    it 'contains the total time' do
      expect(as_json).to include(total_time: 0.84)
    end

    it 'contains the counts', :aggregate_failures do
      expect(as_json).to include(success_count: 0)
      expect(as_json).to include(failed_count: 0)
      expect(as_json).to include(error_count: 4)
      expect(as_json).to include(skipped_count: 0)
      expect(as_json).to include(total_count: 4)
    end

    it 'contains the test suite summary', :aggregate_failures do
      expect(as_json).to include(:test_suite_summary)
      expect(as_json[:test_suite_summary].size).to eq(2)
    end
  end
end
