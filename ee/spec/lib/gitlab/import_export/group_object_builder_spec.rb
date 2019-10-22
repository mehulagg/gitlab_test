# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::GroupObjectBuilder do
  let(:group) { create(:group) }
  let(:base_attributes) do
    {
      'title'       => 'title',
      'description' => 'description',
      'group'       => group
    }
  end

  context 'epics' do
    let(:user) { create(:user) }
    let(:epic_attributes) { base_attributes.merge('author' => user) }

    it 'finds the existing group epic' do
      epic = create(:epic, base_attributes)

      expect(described_class.build(Epic, epic_attributes)).to eq(epic)
    end

    it 'creates a new epic' do
      epic = described_class.build(Epic, epic_attributes)

      expect(epic.persisted?).to be true
    end

    context 'parent epics' do
      let(:parent) { create(:group) }
      let(:group) { create(:group, parent: parent) }

      it 'finds the existing group epic in a parent group' do
        epic = create(:epic, title: 'title', description: 'description', group: parent)

        expect(described_class.build(Epic, epic_attributes)).to eq(epic)
      end
    end
  end
end
