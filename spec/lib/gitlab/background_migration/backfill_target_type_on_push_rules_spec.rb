# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::BackfillTargetTypeOnPushRules, :migration, schema: 2020_03_09_162730 do
  let(:push_rules) { table(:push_rules) }

  subject { described_class.new }

  describe '#perform' do
    it 'updates push rules for all push_rules in range that are connected to project' do
      push_rules.create(id: 5, is_sample: true)
      push_rules.create(id: 7, is_sample: false)
      push_rules.create(id: 8, is_sample: false)

      subject.perform(5, 7)

      expect(push_rules.find(7).target_type).not_to be_nil
      expect(push_rules.find(8).target_type).to eq(nil)
    end

    it 'updates push rules with proper types' do
      push_rules.create(id: 5, is_sample: true)
      push_rules.create(id: 7, is_sample: false)

      subject.perform(5, 7)

      expect(push_rules.find(7).target_type).to eq(described_class::PROJECT_TYPE)
    end
  end
end
