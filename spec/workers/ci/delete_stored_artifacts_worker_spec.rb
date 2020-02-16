# frozen_string_literal: true

require 'spec_helper'

describe Ci::DeleteStoredArtifactsWorker do
  describe '#perform' do
    let(:worker) { described_class.new }
    let(:store_path) { 'file_path' }
    let(:file_store) { ObjectStorage::Store::LOCAL }
    let(:size) { 10 }

    subject { worker.perform(project_id, store_path, file_store, size) }

    before do
      allow(UpdateProjectStatistics).to receive(:update_project_statistics!)
      allow(Ci::DeleteStoredArtifactsService).to receive_message_chain(:new, :execute)
    end

    context 'when project exists' do
      let(:project) { create(:project) }
      let(:project_id) { project.id }

      it 'calls the delete service' do
        expect(Ci::DeleteStoredArtifactsService).to receive_message_chain(:new, :execute).with(store_path, file_store)

        subject
      end

      it 'updates the project statistics' do
        expect(UpdateProjectStatistics).to receive(:update_project_statistics!).with(project, :build_artifacts_size, -size)

        subject
      end
    end

    context 'when project does not exist' do
      let(:project_id) { 12345 }

      it 'calls the delete service' do
        expect(Ci::DeleteStoredArtifactsService).to receive_message_chain(:new, :execute).with(store_path, file_store)

        subject
      end

      it 'does not update the project statistics' do
        expect(UpdateProjectStatistics).not_to receive(:update_project_statistics!)

        subject
      end
    end
  end
end
