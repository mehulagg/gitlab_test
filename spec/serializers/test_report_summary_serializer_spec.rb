# frozen_string_literal: true

require 'spec_helper'

describe TestReportSummarySerializer do
  let(:build_1) { create(:ci_build, :report_results) }
  let(:build_2) { create(:ci_build, :report_results) }
  let(:report_results) { build_1.report_results + build_2.report_results }
  let(:test_report_summary) { Gitlab::Ci::Reports::TestReportSummary.new(report_results) }
  let(:serializer) { described_class.new.represent(test_report_summary) }

  describe '#to_json' do
    subject { serializer.to_json }

    context 'when build has report results' do
      it 'matches the schema' do
        expect(subject).to match_schema('entities/test_report_summary')
      end
    end
  end
end
