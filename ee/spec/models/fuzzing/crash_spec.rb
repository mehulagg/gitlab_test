# frozen_string_literal: true

require 'spec_helper'

describe Fuzzing::Crash do
  it { is_expected.to define_enum_for(:crash_type) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exit_code) }
    it { is_expected.to validate_presence_of(:crash_type) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:job).class_name('Fuzzing::Job') }
  end
end
