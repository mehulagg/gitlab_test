# frozen_string_literal: true

require 'spec_helper'

describe Ci::CreateWebideTerminalService do
  set(:project) { create(:project, :repository) }
  set(:user) { create(:user) }
  let(:ref) { 'master' }

  before do
    stub_licensed_features(ide_terminal: true)
  end

  describe '#execute' do
    subject { described_class.new(project, user, ref: ref).execute }

    context 'for maintainer' do
      shared_examples 'be successful' do
        it 'returns a success with pipeline object' do
          is_expected.to include(status: :success)

          expect(subject[:pipeline]).to be_a(Ci::Pipeline)
          expect(subject[:pipeline]).to be_persisted
          expect(subject[:pipeline].stages.count).to eq(1)
          expect(subject[:pipeline].builds.count).to eq(1)
        end
      end

      before do
        project.add_maintainer(user)
      end

      context 'when web-ide has valid configuration' do
        before do
          stub_webide_config_file(config_content)
        end

        context 'for empty configuration' do
          let(:config_content) do
            'terminal: {}'
          end

          it_behaves_like 'be successful'
        end

        context 'for configuration with container image' do
          let(:config_content) do
            'terminal: { image: ruby }'
          end

          it_behaves_like 'be successful'
        end
      end
    end

    context 'error handling' do
      shared_examples 'having an error' do |message|
        it 'returns an error' do
          is_expected.to eq(
            status: :error,
            message: message
          )
        end
      end

      shared_examples 'having insufficient permissions' do
        it_behaves_like 'having an error', 'Insufficient permissions to create a terminal'
      end

      context 'when user is developer' do
        before do
          project.add_developer(user)
        end

        it_behaves_like 'having insufficient permissions'
      end

      context 'when user is maintainer' do
        before do
          project.add_maintainer(user)
        end

        context 'when terminal is already running' do
          let!(:webide_pipeline) { create(:ee_ci_pipeline, :webide, :running, project: project, user: user) }

          it_behaves_like 'having an error', 'There is already a terminal running'
        end

        context 'when ref is non-existing' do
          let(:ref) { 'non-existing-ref' }

          it_behaves_like 'having an error', 'Ref does not exist'
        end

        context 'when ref is a tag' do
          let(:ref) { 'v1.0.0' }

          it_behaves_like 'having an error', 'Ref needs to be a branch'
        end

        context 'when terminal config is missing' do
          let(:ref) { 'v1.0.0' }

          it_behaves_like 'having an error', 'Ref needs to be a branch'
        end

        context 'when webide config is present' do
          before do
            stub_webide_config_file(config_content)
          end

          context 'config has invalid content' do
            let(:config_content) { 'invalid' }

            it_behaves_like 'having an error', 'Invalid configuration format'
          end

          context 'config is valid, but does not have terminal' do
            let(:config_content) { '{}' }

            it_behaves_like 'having an error', 'Terminal is not configured'
          end
        end
      end
    end
  end
end
