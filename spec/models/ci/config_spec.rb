# frozen_string_literal: true

require 'spec_helper'

describe Ci::Config do
  let(:config) { described_class.new(pipeline) }
  set(:project) { create(:project) }

  let(:pipeline) do
    create(:ci_empty_pipeline, status: :created, project: project)
  end

  describe '#content' do
    let(:implied_yml) { Gitlab::Template::GitlabCiYmlTemplate.find('Auto-DevOps').content }

    context 'when the source is unknown' do
      before do
        expect(config).to receive(:source).and_return(nil)
      end

      it 'returns the configuration if found' do
        allow(pipeline.project.repository).to receive(:gitlab_ci_yml_for)
          .and_return('config')

        expect(config.content).to be_a(String)
        expect(config.content).not_to eq(implied_yml)
        expect(pipeline.yaml_errors).to be_nil
      end

      it 'sets yaml errors in pipeline if not found' do
        expect(config.content).to be_nil
        expect(pipeline.yaml_errors)
            .to start_with('Failed to load CI/CD config file')
      end
    end

    context 'the source is the repository' do
      before do
        expect(config).to receive(:source).and_return(:repository_source)
      end

      it 'returns the configuration if found' do
        allow(pipeline.project.repository).to receive(:gitlab_ci_yml_for)
          .and_return('config')

        expect(config.content).to be_a(String)
        expect(config.content).not_to eq(implied_yml)
        expect(pipeline.yaml_errors).to be_nil
      end

      it 'sets yaml errors in pipeline if not found' do
        expect(config.content).to be_nil
        expect(pipeline.yaml_errors)
            .to start_with('Failed to load CI/CD config file')
      end
    end

    context 'when the source is auto_devops_source' do
      before do
        expect(config).to receive(:source).and_return(:auto_devops_source)
      end

      it 'finds the implied config' do
        expect(config.content).to eq(implied_yml)
        expect(pipeline.yaml_errors).to be_nil
      end
    end
  end

  describe '#path' do
    subject { config.path }

    %i[unknown_source repository_source].each do |source|
      context source.to_s do
        before do
          pipeline.config_source = Ci::Pipeline.config_sources.fetch(source)
        end

        it 'returns the path from project' do
          allow(pipeline.project).to receive(:ci_config_path) { 'custom/path' }

          is_expected.to eq('custom/path')
        end

        it 'returns default when custom path is nil' do
          allow(pipeline.project).to receive(:ci_config_path) { nil }

          is_expected.to eq('.gitlab-ci.yml')
        end

        it 'returns default when custom path is empty' do
          allow(pipeline.project).to receive(:ci_config_path) { '' }

          is_expected.to eq('.gitlab-ci.yml')
        end
      end
    end

    context 'when pipeline is for auto-devops' do
      before do
        pipeline.config_source = 'auto_devops_source'
      end

      it 'does not return config file' do
        is_expected.to be_nil
      end
    end
  end

end
