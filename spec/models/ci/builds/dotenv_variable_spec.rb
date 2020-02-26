# frozen_string_literal: true

require 'spec_helper'

describe Ci::Builds::DotenvVariable do
  let(:variable) { build(:ci_build_dotenv_variable) }

  it_behaves_like 'CI variable' do
    subject { build(:ci_build_dotenv_variable) }
  end

  describe 'Association validation' do
    subject { build(:ci_build_dotenv_variable) }

    it { is_expected.to belong_to(:build) }
    it { is_expected.to validate_uniqueness_of(:key).scoped_to(:build_id) }
  end

  describe 'Count Validation' do
    let(:build) { create(:ci_build) }

    it 'does not allow to build variables more than limit' do
      described_class::MAX_ACCEPTABLE_VARIABLES_COUNT.times do |i|
        build.dotenv_variables.build(key: "KEY#{i}", value: "VALUE#{i}")
      end

      expect(build.dotenv_variables.map(&:valid?).uniq).to eq([true])

      variable = build.dotenv_variables.build(key: 'NEW_KEY', value: 'NEW_VAR')

      expect(variable.valid?).to eq(false)
      expect(variable.errors[:variables])
        .to include("are not allowed to be stored more than #{described_class::MAX_ACCEPTABLE_VARIABLES_COUNT}")
    end
  end
end
