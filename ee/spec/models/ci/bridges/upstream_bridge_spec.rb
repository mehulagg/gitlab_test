# frozen_string_literal: true

require 'spec_helper'

describe Ci::Bridges::UpstreamBridge do
  let(:project) { create(:project) }
  let(:source) { create(:ci_sources_project, project: project) }
  let(:pipeline) { create(:ci_pipeline, project: project, source_project: source) }
  let(:options) { { triggered_by: { project: 'other/project' } } }

  let(:bridge) do
    create(:ci_upstream_bridge, status: :created,
                                options: options,
                                pipeline: pipeline)
  end

  describe 'state machine transitions' do
    context 'when it changes status from created to pending' do
      before do
        bridge.enqueue!
      end

      context 'when the pipeline is triggered by the bridge' do
        let(:options) { { triggered_by: { project: source.source_project.full_path } } }

        it 'marks the bridge as successful' do
          expect(bridge.status).to eq('success')
        end
      end

      context 'when the pipeline is not triggered by the bridge' do
        it 'marks the bridge as skipped' do
          expect(bridge.status).to eq('skipped')
        end
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
