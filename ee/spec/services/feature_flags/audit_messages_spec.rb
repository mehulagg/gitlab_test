# frozen_string_literal: true

require 'spec_helper'

describe FeatureFlags::AuditMessages do
  describe '.strategy_message' do
    it 'returns a message for a cleared rollout percentage' do
      changes = {
        "strategies" => [
          [{ "name" => "gradualRolloutUserId", "parameters" => { "groupId" => "default", "percentage" => "35" } }],
          [{ "name" => "default", "parameters" => {} }]
]
      }

      actual_text = described_class.strategy_message('sandbox', changes)
      expected_text = "Updated rule <strong>sandbox</strong> rollout "\
        "from <strong>35%</strong> to <strong>unset</strong>."

      expect(actual_text).to eq(expected_text)
    end

    it 'returns a message for a changed rollout percentage' do
      changes = {
        "strategies" => [
          [{ "name" => "gradualRolloutUserId", "parameters" => { "groupId" => "default", "percentage" => "20" } }],
          [{ "name" => "gradualRolloutUserId", "parameters" => { "groupId" => "default", "percentage" => "50" } }]
        ]
      }

      actual_text = described_class.strategy_message('sandbox', changes)
      expected_text = "Updated rule <strong>sandbox</strong> rollout "\
        "from <strong>20%</strong> to <strong>50%</strong>."

      expect(actual_text).to eq(expected_text)
    end

    it 'does not return a message when the percentages are the same' do
      changes = {
        "strategies" => [
          [{ "name" => "gradualRolloutUserId", "parameters" => { "groupId" => "default", "percentage" => "75" } }],
          [{ "name" => "gradualRolloutUserId", "parameters" => { "groupId" => "default", "percentage" => "75" } }]
        ]
      }

      expect(described_class.strategy_message('sandbox', changes)).to be_nil
    end
  end
end
