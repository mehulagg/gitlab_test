# frozen_string_literal: true

require 'spec_helper'

describe Ci::ParseDotenvArtifactService do
  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
  let(:build) { create(:ci_build, pipeline: pipeline, project: project) }
  let(:service) { described_class.new(project, nil) }

  describe '#execute' do
    subject { service.execute(build) }

    context 'when build has a dotenv artifact' do
      let!(:artifact) { create(:ci_job_artifact, :dotenv, job: build) }

      it 'parses the artifact' do
        expect(subject[:status]).to eq(:success)

        expect(build.dotenv_variables.as_json).to contain_exactly(
          hash_including('key' => 'KEY1', 'value' => 'VAR1'),
          hash_including('key' => 'KEY2', 'value' => 'VAR2'))
      end

      context 'when parse error happens' do
        before do
          allow_next_instance_of(Gitlab::Ci::Parsers::DotenvVariable) do |parser|
            allow(parser).to receive(:parse!) do
              raise Gitlab::Ci::Parsers::ParserError, 'Invalid Format'
            end
          end
        end

        it 'returns error' do
          expect(Gitlab::ErrorTracking).to receive(:track_exception)
            .with(Gitlab::Ci::Parsers::ParserError, job_id: build.id)

          expect(subject[:status]).to eq(:error)
          expect(subject[:message]).to eq('Invalid Format')
        end

        it 'drops the build' do
          subject
          build.reset

          expect(build).to be_failed
          expect(build.failure_reason.to_sym).to eq(:dotenv_artifact_parse_failure)
        end
      end
    end

    context 'when build does not have a dotenv artifact' do
      it 'returns error' do
        expect(subject[:status]).to eq(:error)
        expect(subject[:message]).to eq('Artifact Not Found')
      end
    end
  end
end
