# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::ExportService do
  describe '#execute' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }
    let(:service) { described_class.new(group.id, user.id) }
    let(:export_creator) { Gitlab::ImportExport::Group::ExportCreator.new(group.id, user.id) }

    before do
      allow(Gitlab::ImportExport::Group::ExportCreator).to receive(:new).with(group.id, user.id).and_return(export_creator)
    end

    it 'creates new group export' do
      expect(export_creator).to receive(:create).and_call_original

      service.execute
    end

    it 'starts import' do
      export = export_creator.create
      allow(service).to receive(:export).and_return(export)
      expect(export).to receive(:start!).and_call_original

      service.execute
      export.reload

      expect(export.status_name).to eq(:started)
    end
  end
end
