# frozen_string_literal: true

require 'spec_helper'

describe Ci::Bridges::UpstreamBridge do
  let(:project) { create(:project) }
  let(:pipeline) { create(:ci_pipeline, project: project) }
  let(:options) { { triggered_by: { project: 'other/project' } } }

  let(:bridge) do
    create(:ci_upstream_bridge, :variables, status: :created,
                                            options: options,
                                            pipeline: pipeline)

    describe 'state machine transitions' do
      context 'when it changes status from created to pending' do
        it 'marks the bridge as successful' do
          bridge.enqueue!

          expect(bridge.status).to eq('success')
        end
      end
    end

    describe '#upstream_project_path' do
      context 'when project is defined' do
        it 'returns a full path of a project' do
          expect(bridge.upstream_project_path).to eq 'other/project'
        end
      end

      context 'when project is not defined' do
        let(:options) { { triggered_by: {} } }

        it 'returns nil' do
          expect(bridge.upstream_project_path).to be_nil
        end
      end
    end
  end
end
