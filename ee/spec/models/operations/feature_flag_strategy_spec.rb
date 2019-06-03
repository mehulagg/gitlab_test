# frozen_string_literal: true

require 'spec_helper'

describe Operations::FeatureFlagStrategy do
  describe 'validations' do
    describe 'name' do
      it { is_expected.to validate_inclusion_of(:name).in_array(%w[default gradualRolloutUserId]) }
    end

    describe 'parameters' do
      let(:scope) { create(:operations_feature_flag_scope) }

      context 'when the strategy name is gradualRolloutUserId' do
        it 'must have a string value for percentage between 0 and 100 inclusive and without a percentage sign' do
          invalid_values = [
            50, 40.0, { key: "value" }, "garbage", "00", "01", "101", "-1", "-10", "0100",
            "1000", "10.0", "5%", "25%", "100hi", "e100", "30m", " ", "\r\n", "\n", "\t",
            "\n10", "20\n", "\n100", "100\n", "\n  ", nil, ""
          ]
          valid_values = %w[
            0 1 10 38 100
          ]

          invalid_values.each do |invalid_value|
            strategy = described_class.create(feature_flag_scope: scope, name: 'gradualRolloutUserId', parameters: { groupId: 'mygroup', percentage: invalid_value })

            expect(strategy.errors[:parameters]).to eq(['percentage must be a string between 0 and 100 inclusive']),
              "invalid value: \"#{invalid_value}\" did not generate a validation error"
          end

          valid_values.each do |valid_value|
            strategy = described_class.create(feature_flag_scope: scope, name: 'gradualRolloutUserId', parameters: { groupId: 'mygroup', percentage: valid_value })

            expect(strategy.errors[:parameters]).to eq([]),
              "valid value: \"#{valid_value}\" generated a validation error"
          end
        end

        it 'must have a string value for groupId' do
          invalid_values = [nil, 4, 50.0, {}]
          invalid_values.each do |invalid_value|
            strategy = described_class.create(feature_flag_scope: scope, name: 'gradualRolloutUserId', parameters: { groupId: invalid_value, percentage: "7" })

            expect(strategy.errors[:parameters]).to eq(['groupId parameter must be a string']),
              "invalid value: \"#{invalid_value}\" did not generate a validation error"
          end
        end
      end

      context 'when the strategy name is default' do
        it 'must be empty' do
          invalid_values = [{ groupId: "hi", percentage: "7" }, "", "nothing", 7]
          invalid_values.each do |invalid_value|
            strategy = described_class.create(feature_flag_scope: scope, name: 'default', parameters: invalid_value)

            expect(strategy.errors[:parameters]).to eq(['parameters must be empty for default strategy']),
              "invalid value: \"#{invalid_value}\" did not generate a validation error"
          end

          valid_values = [nil, {}]
          valid_values.each do |valid_value|
            valid_strategy = described_class.create(feature_flag_scope: scope, name: 'default', parameters: valid_value)
            expect(valid_strategy.errors[:parameters]).to eq([]),
              "valid value: \"#{valid_value}\" generated a validation error"
          end
        end
      end
    end
  end
end
