# frozen_string_literal: true

require 'spec_helper'

describe BuildReportResultEntity do
  let(:build_report_result) { build(:ci_build_report_result) }
  let(:entity) { described_class.new(build_report_result) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains build report result data', :aggregate_failures do
      expect(subject).to include(tests_name: "rspec")
      expect(subject).to include(tests_duration: 0.42)
      expect(subject).to include(tests_success: 0)
      expect(subject).to include(tests_failed: 0)
      expect(subject).to include(tests_errored: 2)
      expect(subject).to include(tests_skipped: 0)
      expect(subject).to include(tests_total: 2)
    end
  end
end
