# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::Parts::Relations do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:export) { create(:group_export, group: group) }
  let(:group_part) { :relations }
  let(:params) do
    {
      group_id: group.id,
      user_id: user.id,
      tmp_dir_path: 'tmp/dir/path',
      config: Gitlab::ImportExport::Config.new(config: Gitlab::ImportExport::Group.config_file).to_h
    }
  end

  subject { described_class.new(group_part, export, params).export_parts }

  describe '#export_parts' do
    it 'creates GroupExportPart relations parts' do
      subject.each do |part|
        expect(part.status_name).to eq(:created)
        expect(part.name).to eq('relations')
        expect(part.params['group_id']).to eq(params[:group_id])
        expect(part.params['user_id']).to eq(params[:user_id])
        expect(part.params['tmp_dir_path']).to eq(params[:tmp_dir_path])
        expect(part.params).to have_key(:relation)
        expect(part.params['relation']).to have_key(:include)
      end
    end
  end
end
