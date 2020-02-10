# frozen_string_literal: true

require 'spec_helper'

describe BuildCoverageWorker do
  describe '#perform' do
    context 'when build exists' do
      let!(:build) { create(:ci_build) }

      it 'updates code coverage' do
        expect_any_instance_of(Ci::Build)
          .to receive(:update_coverage)

        perform_multiple(build.id, exec_times: 1)
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions' do
          let(:job_args) { build.id }
        end
      end
    end

    context 'when build does not exist' do
      it 'does not raise exception' do
        expect { perform_multiple(123) }
          .not_to raise_error
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions' do
          let(:job_args) { nil }
        end
      end
    end
  end
end
