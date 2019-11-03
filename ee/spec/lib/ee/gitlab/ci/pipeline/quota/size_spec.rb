# frozen_string_literal: true

require 'spec_helper'

describe EE::Gitlab::Ci::Pipeline::Quota::Size do
  set(:namespace) { create(:namespace) }
  set(:gold_plan) { create(:gold_plan) }
  set(:project) { create(:project, :repository, namespace: namespace) }

  let(:pipeline) { build_stubbed(:ci_pipeline, project: project) }
  let(:yaml) { Gitlab::Ci::Yaml.new(project: project, sha: project.repository.commit.id) }
  let(:limit) { described_class.new(namespace, pipeline, yaml) }

  before do
    create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
  end

  shared_context 'pipeline size limit exceeded' do
    before do
      config = YAML.dump({
        rspec: { script: 'rspec' },
        spinach: { script: 'spinach' }
      })
      stub_ci_pipeline_yaml_file(config)

      gold_plan.update_column(:pipeline_size_limit, 1)
    end
  end

  shared_context 'pipeline size limit not exceeded' do
    before do
      config = YAML.dump({
        rspec: { script: 'rspec' }
      })
      stub_ci_pipeline_yaml_file(config)

      gold_plan.update_column(:pipeline_size_limit, 2)
    end
  end

  describe '#enabled?' do
    context 'when limit is enabled in plan' do
      before do
        gold_plan.update_column(:pipeline_size_limit, 10)
      end

      it 'is enabled' do
        expect(limit).to be_enabled
      end
    end

    context 'when limit is not enabled' do
      before do
        gold_plan.update_column(:pipeline_size_limit, 0)
      end

      it 'is not enabled' do
        expect(limit).not_to be_enabled
      end
    end
  end

  describe '#exceeded?' do
    context 'when limit is exceeded' do
      include_context 'pipeline size limit exceeded'

      it 'is exceeded' do
        expect(limit).to be_exceeded
      end
    end

    context 'when limit is not exceeded' do
      include_context 'pipeline size limit not exceeded'

      it 'is not exceeded' do
        expect(limit).not_to be_exceeded
      end
    end
  end

  describe '#message' do
    context 'when limit is exceeded' do
      include_context 'pipeline size limit exceeded'

      it 'returns infor about pipeline size limit exceeded' do
        expect(limit.message)
          .to eq "Pipeline size limit exceeded by 1 job!"
      end
    end
  end
end
