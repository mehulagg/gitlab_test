# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::ExportPartWorker do
  let(:group) { create(:group) }
  let(:export) { create(:group_export, group: group) }
  let(:export_part) { create(:group_export_part, export: export) }
  let(:worker) { described_class.new }
  let(:export_service) { Gitlab::ImportExport::Group::ExportPartService }

  describe '#perform' do
    it 'executes ExportPartService' do
      expect_any_instance_of(export_service).to receive(:execute)

      worker.perform(export.id, export_part.id)
    end
  end
end
