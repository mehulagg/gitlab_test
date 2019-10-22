# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::GroupTreeRestorer do
  include ImportExport::CommonUtil

  let(:shared) { Gitlab::ImportExport::Shared.new(group) }

  describe 'restore group tree' do
    before(:context) do
      # Using an admin for import, so we can check assignment of existing members
      user = create(:admin)
      create(:user, username: 'bernard_willms')
      create(:user, username: 'saul_will')

      RSpec::Mocks.with_temporary_scope do
        @group = create(:group, name: 'group', path: 'group')
        @shared = Gitlab::ImportExport::Shared.new(@group)

        setup_import_export_config('group_exports/complex')

        group_tree_restorer = described_class.new(user: user, shared: @shared, group: @group, group_hash: nil)

        @restored_group_json = group_tree_restorer.restore
      end
    end

    context 'JSON' do
      it 'has epics' do
        expect(@group.epics.count).to eq(5)
      end

      it 'has epic parent' do
        parent = @group.epics.first

        @group.epics.last(4) do |epic|
          expect(epic.parent).to eq(parent)
        end
      end
    end
  end
end
