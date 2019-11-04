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

    context 'when file is found in the repository' do
      before do
        allow(pipeline.project.repository).to receive(:gitlab_ci_yml_for) { 'the-config-content'}
      end

      context 'when config is specified in ci_config_path' do
        before do
          project.update!(ci_config_path: 'the-config.yml')
        end

        it 'sets repository source' do
          expect(config.source).to eq(:repository_source)
        end

        it 'sets the content to the one from the repository' do
          expect(config.content).to eq('the-config-content')
        end

        it 'returns the path to the file' do
          expect(config.path).to eq('the-config.yml')
        end
      end

      context 'when config is the default .gitlab-ci.yml' do
        before do
          project.update!(ci_config_path: nil)
        end

        it 'sets repository source' do
          expect(config.source).to eq(:repository_source)
        end

        it 'sets the content to the one from the repository' do
          expect(config.content).to eq('the-config-content')
        end

        it 'returns the path to the file' do
          expect(config.path).to eq('.gitlab-ci.yml')
        end
      end
    end

    context 'when file is not found in the repository' do
      before do
        allow(pipeline.project.repository).to receive(:gitlab_ci_yml_for) { nil }
      end

      context 'when auto-devops is enabled' do
        before do
          allow(project).to receive(:auto_devops_enabled?) { true }
        end

        it 'sets auto-devops source' do
          expect(config.source).to eq(:auto_devops_source)
        end

        it 'sets the content to the one from the implied auto-devops file' do
          auto_devops_content = Gitlab::Template::GitlabCiYmlTemplate.find('Auto-DevOps').content
          expect(config.content).to eq(auto_devops_content)
        end

        context 'when source is unknown' do
          it 'does not return a path' do
            expect(config.path).to eq('.gitlab-ci.yml')
          end
        end

        context 'when source is "auto_devops_source"' do
          it 'does not return a path' do
            config.source # fetch data

            expect(config.path).to be_nil
          end
        end
      end

      context 'when auto-devops is disabled' do
        before do
          allow(project).to receive(:auto_devops_enabled?) { false }
        end

        it 'does not set a source' do
          expect(config.source).to be_nil
        end

        it 'does not set a content' do
          expect(config.content).to be_nil
        end

        it 'returns the path to the default .gitlab-ci.yml' do
          expect(config.path).to eq('.gitlab-ci.yml')
        end
      end
    end
  end
end
