# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CiPlatformMetric do
  subject { build(:ci_platform_metric) }

  it_behaves_like 'a BulkInsertSafe model', CiPlatformMetric do
    let(:valid_items_for_bulk_insertion) { build_list(:ci_platform_metric, 10) }
    let(:invalid_items_for_bulk_insertion) { [] } # class does not have any non-constraint validations defined
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:recorded_at) }
    it { is_expected.to validate_presence_of(:count) }
    it { is_expected.to validate_numericality_of(:count).only_integer.is_greater_than(0) }
    it { is_expected.to allow_values('').for(:platform_target) }
    it { is_expected.not_to allow_values(nil).for(:platform_target) }
    it { is_expected.to validate_length_of(:platform_target).is_at_most(255) }
  end

  describe '.insert_auto_devops_platform_targets!' do
    def platform_target_counts_by_day
      report = Hash.new { |hash, key| hash[key] = {} }
      described_class.all.each do |metric|
        date = metric.recorded_at.to_date
        report[date][metric.platform_target] = metric.count
      end
      report
    end

    context 'when there is already existing metrics data' do
      let!(:metric_1) { create(:ci_platform_metric) }
      let!(:metric_2) { create(:ci_platform_metric) }

      it 'does not erase any existing data' do
        described_class.insert_auto_devops_platform_targets!

        expect(described_class.all.to_a).to contain_exactly(metric_1, metric_2)
      end
    end

    context 'when there are multiple platform target variables' do
      let(:today) { Time.zone.local(1982, 4, 24) }
      let(:tomorrow) { today + 1.day }

      it 'inserts platform target counts for that day' do
        Timecop.freeze(today) do
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'aws')
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'aws')
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'fargate')
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'fargate')
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'fargate')
          described_class.insert_auto_devops_platform_targets!
        end
        Timecop.freeze(tomorrow) do
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'fargate')
          described_class.insert_auto_devops_platform_targets!
        end

        expect(platform_target_counts_by_day).to eq({
          today.to_date => { 'aws' => 2, 'fargate' => 3 },
          tomorrow.to_date => { 'aws' => 2, 'fargate' => 4 }
        })
      end
    end

    context 'when there are ci variable values too long for platform_target' do
      let(:today) { Time.zone.local(1982, 4, 24) }

      it 'truncates those values' do
        max = described_class::PLATFORM_TARGET_MAX_LENGTH
        Timecop.freeze(today) do
          create(:ci_variable, key: described_class::CI_VARIABLE_KEY, value: 'F' * (max + 1))
          described_class.insert_auto_devops_platform_targets!
        end

        expect(platform_target_counts_by_day).to eq({
          today.to_date => { 'F' * max => 1 }
        })
      end
    end

    context 'when there are no platform target variables' do
      it 'does not generate any new platform metrics' do
        create(:ci_variable, key: 'KEY_WHATEVER', value: 'aws')
        described_class.insert_auto_devops_platform_targets!

        expect(platform_target_counts_by_day).to eq({})
      end
    end
  end
end
