# frozen_string_literal: true

require 'spec_helper'

describe Ci::Contextable do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  describe '#scoped_variables' do
    subject { contextable.scoped_variables }

    let(:contextable) { create(:ci_build, pipeline: pipeline, project: project) }

    it 'returns predefined variables' do
      expect(subject.to_hash)
        .to include(
          { 'CI_JOB_NAME' => contextable.name },
          { 'CI_JOB_STAGE' => contextable.stage })
    end

    context 'when contextable has a dotenv variable' do
      let(:contextable) do
        create(:ci_build, pipeline: pipeline, project: project,
                          dotenv_variables: [dotenv_variable])
      end

      let(:dotenv_variable) do
        create(:ci_build_dotenv_variable, key: 'DOTENV_KEY', value: 'DOTENV_KEY')
      end

      it 'returns the variable' do
        expect(subject.to_hash)
          .to include({ 'DOTENV_KEY' => 'DOTENV_KEY' })
      end
    end
  end
end
