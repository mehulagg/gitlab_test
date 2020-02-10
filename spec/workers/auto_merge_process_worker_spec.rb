# frozen_string_literal: true

require 'spec_helper'

describe AutoMergeProcessWorker do
  describe '#perform' do
    subject { perform_multiple(merge_request&.id, exec_times: 1) }

    context 'when merge request is found' do
      let(:merge_request) { create(:merge_request) }

      it 'executes AutoMergeService' do
        expect_next_instance_of(AutoMergeService) do |auto_merge|
          expect(auto_merge).to receive(:process)
        end

        subject
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions' do
          let(:job_args) { merge_request.id }
        end
      end
    end

    context 'when merge request is not found' do
      let(:merge_request) { nil }

      it 'does not execute AutoMergeService' do
        expect(AutoMergeService).not_to receive(:new)

        subject
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions' do
          let(:job_args) { nil }
        end
      end
    end
  end
end
