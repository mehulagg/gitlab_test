# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::AccessibilityReports do
  let(:accessibility_report) { described_class.new }

  describe '#add_url' do
    subject { accessibility_report.add_url(url, data) }

    context 'when url and data is provided' do
      let(:url) { 'https://gitlab.com' }
      let(:data) do
        {
          "code": "WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent",
          "type": "error",
          "typeCode": 1,
          "message": "Anchor element found with a valid href attribute, but no link content has been supplied.",
          "context": "<a href=\"/\" class=\"navbar-brand animated\"><svg height=\"36\" viewBox=\"0 0 1...</a>",
          "selector": "#main-nav > div:nth-child(1) > a",
          "runner": "htmlcs",
          "runnerExtras": {}
        }
      end

      it 'add urls data to the accessibility report' do
        expect { subject }.not_to raise_error

        expect(accessibility_report.urls.size).to eq(1)
      end
    end
  end
end
