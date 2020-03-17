# frozen_string_literal: true

require 'spec_helper'

describe ProjectPushRule do
  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:push_rule) }
  end

  describe 'Validations' do
    let_it_be(:project) { create(:project) }
    let_it_be(:push_rule) { create(:push_rule) }

    it 'validates uniqueness of project' do
      described_class.create!(project: project, push_rule: push_rule)

      expect(described_class.create(project: project, push_rule: create(:push_rule))).not_to be_valid
    end

    it 'validates uniqueness of push rule' do
      described_class.create!(project: project, push_rule: push_rule)

      expect(described_class.create(project: create(:project), push_rule: push_rule)).not_to be_valid
    end
  end
end
