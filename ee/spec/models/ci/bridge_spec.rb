# frozen_string_literal: true

require 'spec_helper'

describe Ci::Bridge do
  let_it_be(:project) { create(:project) }
  let_it_be(:target_project) { create(:project, name: 'project', namespace: create(:namespace, name: 'my')) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  let(:bridge) do
    create(:ci_bridge, :variables, status: :created,
                                   options: options,
                                   pipeline: pipeline)
  end

  let(:options) do
    { trigger: { project: 'my/project', branch: 'master' } }
  end

  it 'belongs to an upstream pipeline' do
    expect(bridge).to belong_to(:upstream_pipeline)
  end

  describe 'state machine transitions' do
    context 'when bridge points towards downstream' do
      it 'does not subscribe to upstream project' do
        expect(::Ci::SubscribeBridgeService).not_to receive(:new)

        bridge.enqueue!
      end
    end

    context 'when bridge points towards upstream' do
      before do
        bridge.options = { bridge_needs: { pipeline: 'my/project' } }
      end

      it 'subscribes to the upstream project' do
        expect(::Ci::SubscribeBridgeService).to receive_message_chain(:new, :execute)

        bridge.enqueue!
      end

      it 'does not schedule downstream pipeline creation' do
        expect(bridge).not_to receive(:schedule_downstream_pipeline!)

        bridge.enqueue!
      end
    end
  end

  describe '#inherit_status_from_upstream!' do
    before do
      bridge.status = 'pending'
      bridge.upstream_pipeline = upstream_pipeline
    end

    subject { bridge.inherit_status_from_upstream! }

    context 'when bridge does not have upstream pipeline' do
      let(:upstream_pipeline) { nil }

      it { is_expected.to be false }
    end

    context 'when upstream pipeline has the same status as the bridge' do
      let(:upstream_pipeline) { build(:ci_pipeline, status: bridge.status) }

      it { is_expected.to be false }
    end

    context 'when status is not supported' do
      (::Ci::Pipeline::AVAILABLE_STATUSES - ::Ci::Pipeline.bridgeable_statuses).each do |status|
        context "when status is #{status}" do
          let(:upstream_pipeline) { build(:ci_pipeline, status: status) }

          it 'returns false' do
            expect(subject).to eq(false)
          end

          it 'does not change the bridge status' do
            expect { subject }.not_to change { bridge.status }.from('pending')
          end
        end
      end
    end

    context 'when status is supported' do
      ::Ci::Pipeline.bridgeable_statuses.each do |status|
        context "when status is #{status}" do
          let(:upstream_pipeline) { build(:ci_pipeline, status: status) }

          it 'inherits the upstream status' do
            expect { subject }.to change { bridge.status }.from('pending').to(status)
          end
        end
      end
    end
  end
end
