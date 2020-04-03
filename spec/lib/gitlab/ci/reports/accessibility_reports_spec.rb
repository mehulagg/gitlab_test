# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::AccessibilityReports do
  let(:accessibility_report) { described_class.new }

  it { expect(accessibility_report.urls).to eq({}) }
end
