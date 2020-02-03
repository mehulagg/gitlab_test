# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::GroupTreeRestorer do
  include ImportExport::CommonUtil

  let(:user) { create(:user) }
  let(:group) { create(:group, name: 'group', path: 'group') }
  let(:shared) { Gitlab::ImportExport::Shared.new(group) }
  let(:group_tree_restorer) { described_class.new(user: user, shared: shared, group: group, group_hash: nil) }

  before do
    setup_import_export_config('group_exports/complex')
    group.add_owner(user)
    group_tree_restorer.restore
  end

  describe 'restore group tree' do
    context 'epics' do
      it 'has group epics' do
        expect(group.epics.count).to eq(5)
      end

      it 'has award emoji' do
        expect(group.epics.first.award_emoji.first.name).to eq('thumbsup')
      end
    end

    context 'epic notes' do
      it 'has epic notes' do
        expect(group.epics.first.notes.count).to eq(4)
      end

      it 'has award emoji on epic notes' do
        expect(group.epics.first.notes.first.award_emoji.first.name).to eq('drum')
      end
    end
  end
end
