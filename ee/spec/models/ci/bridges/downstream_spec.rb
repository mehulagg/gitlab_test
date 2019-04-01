# frozen_string_literal: true

require 'spec_helper'

describe Ci::Bridges::Downstream do
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

  describe '#target_ref' do
    context 'when trigger is defined' do
      it 'returns a ref name' do
        expect(bridge.target_ref).to eq 'master'
      end
    end

    context 'when trigger does not have project defined' do
      let(:options) { nil }

      it 'returns nil' do
        expect(bridge.target_ref).to be_nil
      end
    end
  end

  describe '#yaml_variables' do
    it 'returns YAML variables' do
      expect(bridge.yaml_variables)
        .to include(key: 'BRIDGE', value: 'cross', public: true)
    end
  end

  describe '#downstream_variables' do
    it 'returns variables that are going to be passed downstream' do
      expect(bridge.downstream_variables)
        .to include(key: 'BRIDGE', value: 'cross')
    end
  end
end
