# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::Exporters::Base do
  let(:export) { create(:group_export) }
  let(:part) { create(:group_export_part, :started, export: export) }

  subject { described_class.new(part) }

  describe '#export' do
    let(:tmp_dir_path) { 'tmp/dir/path'}
    let(:export_path) { Gitlab::ImportExport::Group.export_path(tmp_dir_path) }

    before do
      allow(subject).to receive(:tmp_dir_path).and_return(tmp_dir_path)
    end

    it 'creates temporary directory' do
      subject.export

      expect(File.directory?(export_path)).to eq(true)
    end

    it 'marks part export as finished' do
      subject.export

      expect(part.finished?).to eq(true)
    end

    context 'when part export fails' do
      before do
        allow(subject).to receive(:export_part).and_raise(StandardError.new('Error!'))
      end

      it 'marks part export as failed' do
        subject.export

        expect(part.failed?).to eq(true)
        expect(part.status_reason).to eq({ error: 'Error!' }.to_s)
      end
    end
  end
end
