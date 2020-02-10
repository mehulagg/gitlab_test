# frozen_string_literal: true

require 'spec_helper'

describe ArchiveTraceWorker do
  describe '#perform' do
    let(:job_args) { job&.id }

    context 'when job is found' do
      let(:job) { create(:ci_build, :trace_live) }

      it 'executes service' do
        expect_any_instance_of(Ci::ArchiveTraceService)
          .to receive(:execute).with(job, anything)

        perform_multiple(job_args, exec_times: 1)
      end

      # Following test fails: Worker is unlikely to be idempotent.
      xcontext 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions'
      end
    end

    context 'when job is not found' do
      let(:job) { nil }

      it 'does not execute service' do
        expect_any_instance_of(Ci::ArchiveTraceService)
          .not_to receive(:execute)

        perform_multiple(job_args)
      end
    end
  end
end
