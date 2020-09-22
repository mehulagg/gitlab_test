# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::InstanceStatistics::CountJobTriggerWorker do
  it_behaves_like 'an idempotent worker'

  context 'triggers a job for each measurement identifiers' do
    let(:expected_count) { Analytics::InstanceStatistics::Measurement.identifiers.size }

    it 'triggers CounterJobWorker jobs' do
      subject.perform

      expect(Analytics::InstanceStatistics::CounterJobWorker.jobs.count).to eq(expected_count)
    end
  end

  context 'when the `store_instance_statistics_measurements` feature flag is off' do
    before do
      stub_feature_flags(store_instance_statistics_measurements: false)
    end

    it 'does not trigger any CounterJobWorker job' do
      subject.perform

      expect(Analytics::InstanceStatistics::CounterJobWorker.jobs.count).to eq(0)
    end
  end

  context 'when the `store_ci_pipeline_counts_by_status` feature flag is off' do
    let(:expected_count) { Analytics::InstanceStatistics::Measurement.identifiers.size - Analytics::InstanceStatistics::Measurement::CI_PIPELINE_STATUS_MAPPING.size }

    before do
      stub_feature_flags(store_ci_pipeline_counts_by_status: false)
    end

    it 'does not trigger worker for Ci::Pipeline status specific counts' do
      subject.perform

      expect(Analytics::InstanceStatistics::CounterJobWorker.jobs.count).to eq(expected_count)
    end
  end
end
