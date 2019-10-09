# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::ExportPartService do
  describe '#execute' do
    let(:export) { create(:group_export) }
    let!(:part) { create(:group_export_part, :scheduled, export: export) }
    let(:service) { described_class.new(export.id, part.id) }

    before do
      allow(service).to receive(:part).and_return(part)
    end

    it 'starts part export' do
      expect(part).to receive(:start!).and_call_original

      service.execute

      expect(part.reload.status_name).to eq(:finished)
    end

    context 'when part export start fails' do
      before do
        allow(part).to receive(:start!).and_raise(StandardError.new('Something went wrong'))
      end

      it 'updates status_reason' do
        service.execute
        part.reload

        expect(part.status_name).to eq(:failed)
        expect(part.status_reason).to eq({ error: 'Something went wrong' }.to_s)
      end
    end
  end
end
