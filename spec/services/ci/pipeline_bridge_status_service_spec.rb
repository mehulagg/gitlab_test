# frozen_string_literal: true

require 'spec_helper'

describe Ci::PipelineBridgeStatusService do
  let(:user) { build(:user) }
  let(:project) { build(:project) }
  let(:pipeline) { build(:ci_pipeline, project: project) }

  describe '#execute' do
    subject { described_class.new(project, user).execute(pipeline) }

    context 'when pipeline has upstream bridge' do
      let(:bridge) { build(:ci_bridge) }

      before do
        pipeline.source_bridge = bridge
      end

      context 'when bridge is dependent' do
        before do
          expect(bridge).to receive(:dependent?).and_return(true)
        end

        it 'calls inherit_status_from_downstream on upstream bridge' do
          expect(bridge).to receive(:inherit_status_from_downstream!).with(pipeline)

          subject
        end
      end

      context 'when bridge is not dependent' do
        it 'does not proceed' do
          expect(bridge).not_to receive(:inherit_status_from_downstream!)

          subject
        end
      end
    end

    context 'when pipeline does not have upstream bridge' do
      it 'does not do anything' do
        expect(pipeline).not_to receive(:bridge_waiting?)

        subject
      end
    end
  end
end
