# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::BuildReportResultService do
  describe '#execute', :clean_gitlab_redis_shared_state do
    subject(:build_report_result) { described_class.new.execute(build) }

    context 'when build is finished' do
      let(:build) { create(:ci_build, :success, :test_reports) }

      it 'creates a build report result entry', :aggregate_failures do
        expect_any_instance_of(Gitlab::Tracking::TestCasesParsed).to receive(:track_event).and_call_original
        expect(build_report_result.tests_name).to eq("test")
        expect(build_report_result.tests_success).to eq(2)
        expect(build_report_result.tests_failed).to eq(2)
        expect(build_report_result.tests_errored).to eq(0)
        expect(build_report_result.tests_skipped).to eq(0)
        expect(build_report_result.tests_duration).to eq(0.010284)
        expect(Ci::BuildReportResult.count).to eq(1)
      end

      context 'when feature flag for tracking is disabled' do
        before do
          stub_feature_flags(track_unique_test_cases_parsed: false)
        end

        it 'creates the report but does not track the event' do
          expect_any_instance_of(Gitlab::Tracking::TestCasesParsed).not_to receive(:track_event)
          expect(build_report_result.tests_name).to eq("test")
          expect(Ci::BuildReportResult.count).to eq(1)
        end
      end

      context 'when data has already been persisted' do
        it 'raises an error and do not persist the same data twice' do
          expect { 2.times { described_class.new.execute(build) } }.to raise_error(ActiveRecord::RecordNotUnique)

          expect(Ci::BuildReportResult.count).to eq(1)
        end
      end
    end

    context 'when build is running and test report does not exist' do
      let(:build) { create(:ci_build, :running) }

      it 'does not persist data' do
        subject

        expect(Ci::BuildReportResult.count).to eq(0)
      end
    end
  end
end
