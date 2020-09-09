# frozen_string_literal: true

require 'fast_spec_helper'

require 'rspec-parameterized'
require 'rubocop'
require 'rubocop/rspec/support'

require_relative '../../../../rubocop/cop/rspec/expect_gitlab_tracking'

RSpec.describe RuboCop::Cop::RSpec::ExpectGitlabTracking do
  include CopHelper

  let(:source_file) { 'spec/foo_spec.rb' }

  subject(:cop) { described_class.new }

  it 'matches for event with' do
    code = <<~CODE
      expect(Gitlab::Tracking).to receive(:event).with(
        'Growth::Conversion::Experiment::OnboardingIssues',
        'signed_up',
        label: anything,
        property: 'foobar'
      )
    CODE

    inspect_source(code)

    expect(cop.offenses.size).to eq(1)
  end

  it 'matches for event with not' do
    code = <<~CODE
      expect(Gitlab::Tracking).not_to receive(:event).with(
        'Growth::Conversion::Experiment::OnboardingIssues',
        'signed_up',
        label: anything,
        property: 'foobar'
      )
    CODE

    inspect_source(code)

    expect(cop.offenses.size).to eq(1)
  end

  it 'matches for event' do
    code = <<~CODE
      expect(Gitlab::Tracking).to receive(:event)
    CODE

    inspect_source(code)

    expect(cop.offenses.size).to eq(1)
  end

  it 'matches for not receiving an event' do
    code = <<~CODE
      expect(Gitlab::Tracking).not_to receive(:event)
    CODE

    inspect_source(code)

    expect(cop.offenses.size).to eq(1)
  end
end
