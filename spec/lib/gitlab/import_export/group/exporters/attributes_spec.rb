# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::Exporters::Attributes do
  let(:export) { create(:group_export) }
  let!(:label) { create(:group_label, group: export.group) }
  let(:part) { create(:group_export_part, :started, export: export) }

  subject { described_class.new(part) }

  describe '#export_part' do
    let(:tmp_dir_path) { export.group.full_path }
    let(:export_path) { Gitlab::ImportExport::Group.export_path(tmp_dir_path) }

    before do
      allow(subject).to receive(:tmp_dir_path).and_return(tmp_dir_path)
    end

    it 'writes group attributes to file' do
      subject.export

      exported_group = JSON.parse(File.read(export_path << "/#{Gitlab::ImportExport::Group.group_filename}"))
      expect(exported_group['id']).to eq(export.group.id)
    end
  end
end
