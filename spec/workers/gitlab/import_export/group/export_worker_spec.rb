# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::ExportWorker do
  let(:group) { create(:group) }
  let(:user) { create(:user) }
  let(:worker) { described_class.new }
  let(:export_service) { Gitlab::ImportExport::Group::ExportService }

  describe '#perform' do
    it 'executes ExportService' do
      expect_any_instance_of(export_service).to receive(:execute)

      worker.perform(group.id, user.id)
    end
  end
end
