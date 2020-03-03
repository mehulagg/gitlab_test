# frozen_string_literal: true

require 'spec_helper'

describe VulnerabilitiesSummary do
  subject { described_class.new }

  it 'defines a method for each vulnerability severity' do
    ::Vulnerabilities::Occurrence::SEVERITY_LEVELS.keys.each do |severity|
      is_expected.to respond_to(severity)
    end
  end

  it 'defines a #vulnerable method' do
    is_expected.to respond_to(:vulnerable)
  end

  it 'accepts keyword arguments' do
    summary = described_class.new(high: 42)

    expect(summary.high).to be(42)
  end
end
