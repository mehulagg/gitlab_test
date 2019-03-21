# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Pipeline::Seed::Build do
  let(:project) { create(:project, :repository) }
  let(:pipeline) { create(:ci_empty_pipeline, project: project) }

  subject do
    described_class.new(pipeline, attributes)
  end

  describe '#to_resource' do
    context 'when job is a bridge' do
      context 'when bridge is downstream' do
        let(:attributes) do
          { name: 'rspec', ref: 'master', options: { trigger: 'my/project' } }
        end

        it 'returns a valid bridge resource' do
          expect(subject.to_resource).to be_a(::Ci::Bridges::DownstreamBridge)
          expect(subject.to_resource).to be_valid
        end
      end

      context 'when bridge is upstream' do
        let(:attributes) do
          { name: 'rspec', ref: 'master', options: { triggered_by: 'my/project' } }
        end

        it 'returns a valid bridge resource' do
          expect(subject.to_resource).to be_a(::Ci::Bridges::UpstreamBridge)
          expect(subject.to_resource).to be_valid
        end
      end
    end
  end
end
