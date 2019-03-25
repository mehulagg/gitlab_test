# frozen_string_literal: true

require 'spec_helper'

describe ::Gitlab::Ci::Pipeline::Chain::PopulateSourceProject do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:pipeline) { build(:ci_pipeline, project: project, ref: 'master') }
  let(:command) { Gitlab::Ci::Pipeline::Chain::Command.new(project: project, current_user: user) }

  let(:step) { described_class.new(pipeline, command) }

  subject { step.perform! }

  context 'when cross-project pipelines are enabled' do
    before do
      stub_licensed_features(cross_project_pipelines: true)
    end

    context 'when the upstream project exists' do
      let(:upstream_project) { create(:project) }

      before do
        pipeline.stages.build(name: 'test', position: 0, project: project)
        pipeline.stages.first.bridges << build(:ci_upstream_bridge, upstream: upstream_project)
      end

      context 'when the user has permissions' do
        before do
          upstream_project.add_developer(user)
          project.add_developer(user)
        end

        it 'populates the pipeline project source' do
          subject

          expect(pipeline.source_project).to be_present
          expect(pipeline.source_project.source_project).to eq(upstream_project)
        end

        it 'does not break the chain' do
          subject

          expect(step.break?).to be false
        end
      end

      context 'when the user does not have permissions' do
        it 'does not populate the pipeline project source' do
          subject

          expect(pipeline.source_project).not_to be_present
        end

        it 'breaks the chain' do
          subject

          expect(step.break?).to be true
        end
      end
    end

    context 'when the upstream project does not exist' do
      before do
        pipeline.stages.build(name: 'test', position: 0, project: project)
        pipeline.stages.first.bridges << build(:ci_upstream_bridge, :invalid_upstream)
      end

      it 'drops the bridge job' do
        subject

        expect(pipeline.stages.first.bridges.first.status).to eq('failed')
        expect(pipeline.stages.first.bridges.first.failure_reason).to eq('upstream_bridge_project_not_found')
      end

      it 'does not break the chain' do
        subject

        expect(step.break?).to be false
      end
    end

    context 'when the pipeline is not on the default branch' do
      let(:pipeline) { build(:ci_pipeline, project: project, ref: 'some_branch') }

      it 'does not populate the pipeline project source' do
        subject

        expect(pipeline.source_project).not_to be_present
      end

      it 'does not break the chain' do
        subject

        expect(step.break?).to be false
      end
    end
  end

  context 'when cross-project pipelines are not enabled' do
    let(:pipeline) { build(:ci_pipeline, project: project, ref: 'some_branch') }

    it 'does not populate the pipeline project source' do
      subject

      expect(pipeline.source_project).not_to be_present
    end

    it 'does not break the chain' do
      subject

      expect(step.break?).to be false
    end
  end
end
