# frozen_string_literal: true

require 'spec_helper'

describe Fuzzing::Job do
  it { is_expected.to define_enum_for(:job_type) }
  it { is_expected.to define_enum_for(:status) }

  describe 'associations' do
    it { is_expected.to have_one(:pipeline).class_name('Ci::Pipeline') }
    it { is_expected.to belong_to(:build).class_name('Ci::Build') }
    it { is_expected.to belong_to(:target).class_name('Fuzzing::Target') }
    it { is_expected.to have_many(:crashes).class_name('Fuzzing::Crash') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:build_id) }
    it { is_expected.to validate_presence_of(:job_type) }
  end
end
