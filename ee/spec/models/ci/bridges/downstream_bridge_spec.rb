# frozen_string_literal: true

require 'spec_helper'

describe Ci::Bridges::DownstreamBridge do
  let(:project) { create(:project) }
  let(:pipeline) { create(:ci_pipeline, project: project) }

  let(:options) do
    { trigger: { project: 'my/project', branch: 'master' } }
  end
  let(:bridge) do
    create(:ci_downstream_bridge, :variables, status: :created,
                                              options: options,
                                              pipeline: pipeline)
  end

  it 'has many sourced pipelines' do
    expect(bridge).to have_many(:sourced_pipelines)
  end

  describe 'state machine transitions' do
    context 'when it changes status from created to pending' do
      it 'schedules downstream pipeline creation' do
        expect(bridge).to receive(:schedule_downstream_pipeline!)

        bridge.enqueue!
      end
    end
  end

  describe '#downstream_project_path' do
    context 'when project is defined' do
      it 'returns a full path of a project' do
        expect(bridge.downstream_project_path).to eq 'my/project'
      end
    end

    context 'when project is not defined' do
      let(:options) { { trigger: {} } }

      it 'returns nil' do
        expect(bridge.downstream_project_path).to be_nil
      end
    end
  end
end
