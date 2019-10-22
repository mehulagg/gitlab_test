# frozen_string_literal: true

require 'spec_helper'

describe Groups::ImportExport::ExportService do
  describe '#execute' do
    let!(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:shared) { Gitlab::ImportExport::Shared.new(group) }
    let(:export_path) { shared.export_path }
    let(:service) { described_class.new(group: group, user: user) }

    before do
      allow(service).to receive(:shared).and_return(shared)
    end

    it 'saves the models' do
      expect(Gitlab::ImportExport::GroupTreeSaver).to receive(:new).and_call_original

      service.execute
    end

    context 'when saver succeeds' do
      it 'saves the group in the file system' do
        expect(Gitlab::ImportExport::Saver).to receive(:save).with(exportable: group, shared: shared)

        service.execute
      end
    end

    context 'when saving services fail' do
      before do
        allow(service).to receive_message_chain(:tree_exporter, :save).and_return(false)
      end

      after do
        expect { service.execute }.to raise_error(Gitlab::ImportExport::Error)
      end

      it 'removes the remaining exported data' do
        allow(FileUtils).to receive(:rm_rf)
        expect(FileUtils).to receive(:rm_rf).with(shared.export_path).once
      end

      it 'notifies logger' do
        expect_any_instance_of(Gitlab::Import::Logger).to receive(:error)
      end
    end
  end
end
