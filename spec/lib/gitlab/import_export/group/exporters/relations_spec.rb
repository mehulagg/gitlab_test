# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::Exporters::Relations do
  let(:export) { create(:group_export) }
  let!(:label) { create(:group_label, group: export.group, title: 'label') }
  let(:part) do
    create(
      :group_export_part,
      :started,
      export: export,
      params: {
        group_id: export.group.id,
        relation: { include: { labels: { include: [] } } }
      }
    )
  end
  let(:filename) { 'labels.json' }

  subject { described_class.new(part) }

  describe '#export_part' do
    let(:tmp_dir_path) { export.group.full_path }
    let(:export_path) { Gitlab::ImportExport::Group.export_path(tmp_dir_path) }

    before do
      allow(subject).to receive(:tmp_dir_path).and_return(tmp_dir_path)
    end

    it 'writes group labels relation to file' do
      subject.export

      exported_label = JSON.parse(File.read(export_path << "/#{filename}")).first
      expect(exported_label['title']).to eq(label.title)
    end
  end
end
