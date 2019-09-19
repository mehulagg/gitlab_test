# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::ExportCreator do
  let(:group) { create(:group) }
  let(:user) { create(:user) }
  let(:export_creator) { described_class.new(group.id, user.id) }
  subject { export_creator.create }

  describe '#create' do
    it 'creates export' do
      expect(subject).to be_instance_of(GroupExport)
      expect(subject.persisted?).to eq(true)
      expect(subject.status).to eq('created')
    end

    it 'creates export parts' do
      expect(subject.parts.first).to be_instance_of(GroupExportPart)
    end

    context 'when export cannot be saved' do
      before do
        allow(Group).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
