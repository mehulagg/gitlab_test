# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::Parts::Attributes do
  let(:group) { create(:group) }
  let(:export) { create(:group_export, group: group) }
  let(:group_part) { :attributes }
  let(:params) do
    {
      group_id: group.id,
      tmp_dir_path: 'tmp/dir/path'
    }
  end

  subject { described_class.new(group_part, export, params).export_parts }

  describe '#export_parts' do
    it 'creates attributes GroupExportPart' do
      expect(subject.status_name).to eq(:created)
      expect(subject.name).to eq('attributes')
      expect(subject.params['group_id']).to eq(params[:group_id])
      expect(subject.params['tmp_dir_path']).to eq(params[:tmp_dir_path])
    end
  end
end
