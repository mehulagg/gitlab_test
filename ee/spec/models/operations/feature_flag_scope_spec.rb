# frozen_string_literal: true

require 'spec_helper'

describe Operations::FeatureFlagScope do
  describe 'associations' do
    it { is_expected.to belong_to(:feature_flag) }
  end

  describe 'validations' do
    context 'when duplicate environment scope is going to be created' do
      let!(:existing_feature_flag_scope) do
        create(:operations_feature_flag_scope)
      end

      let(:new_feature_flag_scope) do
        build(:operations_feature_flag_scope,
          feature_flag: existing_feature_flag_scope.feature_flag,
          environment_scope: existing_feature_flag_scope.environment_scope)
      end

      it 'validates uniqueness of environment scope' do
        new_feature_flag_scope.save

        expect(new_feature_flag_scope.errors[:environment_scope])
          .to include("(#{existing_feature_flag_scope.environment_scope})" \
                      " has already been taken")
      end
    end

    context 'when environment scope of a default scope is updated' do
      let!(:feature_flag) { create(:operations_feature_flag) }
      let!(:default_scope) { feature_flag.default_scope }

      it 'keeps default scope intact' do
        default_scope.update(environment_scope: 'review/*')

        expect(default_scope.errors[:environment_scope])
          .to include("cannot be changed from default scope")
      end
    end

    context 'when a default scope is destroyed' do
      let!(:feature_flag) { create(:operations_feature_flag) }
      let!(:default_scope) { feature_flag.default_scope }

      it 'prevents from destroying the default scope' do
        expect { default_scope.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end

    describe 'strategy validations' do
      it 'validates multiple strategies' do
        feature_flag = create(:operations_feature_flag)
        scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: "default", parameters: {} }, { name: "invalid", parameters: {} }])

        expect(scope.errors[:strategies]).not_to be_empty
      end

      describe 'name' do
        it 'must be one of "default" or "gradualRolloutUserId"' do
          valid_values = [
            ['default', {}],
            ['gradualRolloutUserId', { groupId: 'mygroup', percentage: '50' }]
          ]
          invalid_values = [5, nil, "nothing", "", 40.0, {}, []]

          valid_values.each do |valid_name, params|
            feature_flag = create(:operations_feature_flag)
            scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: valid_name, parameters: params }])

            expect(scope.errors[:strategies]).to eq([]),
              "valid name: \"#{valid_name}\" generated a validation error"
          end

          invalid_values.each do |invalid_value|
            feature_flag = create(:operations_feature_flag)
            scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: invalid_value }])

            expect(scope.errors[:strategies]).to eq(['strategy name is invalid']),
              "invalid value: \"#{invalid_value}\" did not generate a validation error"
          end
        end
      end

      describe 'parameters' do
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
              feature_flag = create(:operations_feature_flag)
              scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'gradualRolloutUserId',
                                                                                       parameters: { groupId: 'mygroup', percentage: invalid_value } }])

              expect(scope.errors[:strategies]).to eq(['percentage must be a string between 0 and 100 inclusive']),
                "invalid value: \"#{invalid_value}\" did not generate a validation error"
            end

            valid_values.each do |valid_value|
              feature_flag = create(:operations_feature_flag)
              scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'gradualRolloutUserId',
                                                                                       parameters: { groupId: 'mygroup', percentage: valid_value } }])

              expect(scope.errors[:strategies]).to eq([]),
                "valid value: \"#{valid_value}\" generated a validation error"
            end
          end

          it 'must have a string value for groupId of up to 32 lowercase characters' do
            invalid_values = [nil, 4, 50.0, {}, 'spaces bad', 'bad$', '%bad', '<bad', 'bad>', '!bad',
                              '.bad', 'Bad', 'bad1', "", " ", "b" * 33, "ba_d", "ba\nd"]
            invalid_values.each do |invalid_value|
              feature_flag = create(:operations_feature_flag)
              scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'gradualRolloutUserId',
                                                                                       parameters: { groupId: invalid_value, percentage: '40' } }])

              expect(scope.errors[:strategies]).to eq(['groupId parameter is invalid']),
                "invalid value: \"#{invalid_value}\" did not generate a validation error"
            end

            valid_values = ["somegroup", "anothergroup", "okay", "g", "a" * 32]
            valid_values.each do |valid_value|
              feature_flag = create(:operations_feature_flag)
              scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'gradualRolloutUserId',
                                                                                       parameters: { groupId: valid_value, percentage: '40' } }])

              expect(scope.errors[:strategies]).to eq([]),
                "valid value: \"#{valid_value}\" generated a validation error"
            end
          end

          it 'must have parameters' do
            feature_flag = create(:operations_feature_flag)
            scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'gradualRolloutUserId' }])
            expect(scope.errors[:strategies]).to include('groupId parameter is invalid')
            expect(scope.errors[:strategies]).to include('percentage must be a string between 0 and 100 inclusive')
          end
        end

        context 'when the strategy name is default' do
          it 'must be empty' do
            invalid_values = [{ groupId: "hi", percentage: "7" }, "", "nothing", 7, nil]
            invalid_values.each do |invalid_value|
              feature_flag = create(:operations_feature_flag)
              scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'default',
                                                                                       parameters: invalid_value }])

              expect(scope.errors[:strategies]).to eq(['parameters must be empty for default strategy']),
                "invalid value: \"#{invalid_value}\" did not generate a validation error"
            end

            feature_flag = create(:operations_feature_flag)
            scope = described_class.create(feature_flag: feature_flag, strategies: [{ name: 'default',
                                                                                     parameters: {} }])

            expect(scope.errors[:strategies]).to eq([]),
              "valid value: {} generated a validation error"
          end
        end
      end
    end
  end

  describe '.enabled' do
    subject { described_class.enabled }

    let!(:feature_flag_scope) do
      create(:operations_feature_flag_scope, active: active)
    end

    context 'when scope is active' do
      let(:active) { true }

      it 'returns the scope' do
        is_expected.to include(feature_flag_scope)
      end
    end

    context 'when scope is inactive' do
      let(:active) { false }

      it 'returns an empty array' do
        is_expected.not_to include(feature_flag_scope)
      end
    end
  end

  describe '.disabled' do
    subject { described_class.disabled }

    let!(:feature_flag_scope) do
      create(:operations_feature_flag_scope, active: active)
    end

    context 'when scope is active' do
      let(:active) { true }

      it 'returns an empty array' do
        is_expected.not_to include(feature_flag_scope)
      end
    end

    context 'when scope is inactive' do
      let(:active) { false }

      it 'returns the scope' do
        is_expected.to include(feature_flag_scope)
      end
    end
  end
end
