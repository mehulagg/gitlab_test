# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::BackfillPushRules, :migration, schema: 2020_03_09_162730 do
  let(:push_rules) { table(:push_rules) }

  subject { described_class.new }

  describe '#perform' do
    it 'updates push rules for all push_rules in range' do
      push_rules.create(id: 5, is_sample: true)
      push_rules.create(id: 7, is_sample: false)
      push_rules.create(id: 8, is_sample: false)

      subject.perform(5, 7)

      expect(push_rules.where(id: 5..7).pluck(:target_type)).not_to include(nil)
      expect(push_rules.find(8).target_type).to eq(nil)
    end

    it 'updates push rules with proper types' do
      push_rules.create(id: 5, is_sample: true)
      push_rules.create(id: 7, is_sample: false)

      subject.perform(5, 7)

      expect(push_rules.find(5).target_type).to eq(described_class::TYPES_HASH[:instance])
      expect(push_rules.find(7).target_type).to eq(described_class::TYPES_HASH[:project])
    end
  end
end
