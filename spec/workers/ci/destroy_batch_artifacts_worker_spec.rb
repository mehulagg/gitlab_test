# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DestroyBatchArtifactsWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    let!(:artifact) { create(:ci_job_artifact) }

    it 'removes artifacts' do
      expect { worker.perform([artifact.id]) }.to change { Ci::JobArtifact.count }.by(-1)
    end
  end
end
