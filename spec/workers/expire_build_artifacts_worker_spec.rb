# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExpireBuildArtifactsWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    context 'with ci_batch_artifacts_cron_removal feature flag disabled' do
      before do
        stub_feature_flags(ci_batch_artifacts_cron_removal: false)
      end

      it 'executes a service' do
        expect_next_instance_of(Ci::DestroyExpiredJobArtifactsService) do |instance|
          expect(instance).to receive(:execute)
        end

        worker.perform
      end
    end

    context 'with ci_batch_artifacts_cron_removal feature flag enabled' do
      before do
        stub_feature_flags(ci_batch_artifacts_cron_removal: true)
      end

      it 'executes a service' do
        expect_next_instance_of(Ci::Artifacts::BatchEnqueueRemovalService) do |instance|
          expect(instance).to receive(:execute)
        end

        worker.perform
      end
    end
  end
end
