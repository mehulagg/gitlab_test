# frozen_string_literal: true

require 'spec_helper'

describe Operations::FeatureFlagStrategy do
  describe 'validations' do
    describe 'parameters.percentage' do
      it 'must be a string between 0 and 100 inclusive and without a percentage sign' do
        invalid_values = [
          50, 40.0, { key: "value" }, "garbage", "00", "01", "101", "-1", "-10", "0100",
          "1000", "10.0", "5%", "25%", "100hi", "e100", "30m", " ", "\r\n", "\n", "\t",
          "\n10", "20\n", "\n100", "100\n", "\n  ", nil, ""
        ]
        valid_values = %w[
          0 1 10 38 100
        ]

        invalid_values.each do |invalid_value|
          strategy = described_class.create(name: 'gradualRolloutUserId', parameters: { groupId: 'mygroup', percentage: invalid_value })

          expect(strategy.errors[:parameters]).to eq(['percentage must be a string between 0 and 100 inclusive']),
            "invalid value: \"#{invalid_value}\" did not generate a validation error"
        end

        valid_values.each do |valid_value|
          strategy = described_class.create(name: 'gradualRolloutUserId', parameters: { groupId: 'mygroup', percentage: valid_value })

          expect(strategy.errors[:parameters]).to eq([]),
            "valid value: \"#{valid_value}\" generated a validation error"
        end
      end
    end

    describe 'parameters.groupId' do
      it 'must be set if the percentage parameter is set' do
        strategy = described_class.create(name: 'gradualRolloutUserId', parameters: { percentage: "7" })

        expect(strategy.errors[:parameters]).to eq(['groupId parameter is required if percentage parameter is set'])
      end

      it 'must be a string' do
        invalid_values = [4, 50.0, {}]
        invalid_values.each do |invalid_value|
          strategy = described_class.create(name: 'gradualRolloutUserId', parameters: { groupId: invalid_value, percentage: "7" })

          expect(strategy.errors[:parameters]).to eq(['groupId parameter must be a string']),
            "invalid value: \"#{invalid_value}\" did not generate a validation error"
        end
      end
    end

    describe 'name' do
      it 'must be equal to gradualRolloutUserId if percentage is set' do
        strategy = described_class.create(name: 'default', parameters: { percentage: "40" })

        expect(strategy.errors[:name]).to eq(['must be gradualRolloutUserId if percentage parameter is set'])
      end

      it 'must be equal to default if percentage is not set' do
        strategy = described_class.create(name: 'gradualRolloutUserId', parameters: {})

        expect(strategy.errors[:name]).to eq(['must be default if percentage parameter is not set'])
      end
    end
  end
end
