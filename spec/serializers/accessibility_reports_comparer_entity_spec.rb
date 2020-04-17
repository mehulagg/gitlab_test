# frozen_string_literal: true

require 'spec_helper'

describe AccessibilityReportsComparerEntity do
  let(:entity) { described_class.new(comparer) }
  let(:comparer) { Gitlab::Ci::Reports::AccessibilityReportsComparer.new(base_report, head_report) }
  let(:base_report) { Gitlab::Ci::Reports::AccessibilityReports.new }
  let(:head_report) { Gitlab::Ci::Reports::AccessibilityReports.new }

  describe '#as_json' do
    subject { entity.as_json }

    context 'when head report has a newly failed which does not exist in base' do
      before do
        base_report.errors = 1
        base_report.urls = {
          "https://gitlab.com" =>
            [
              {
                "code" => "WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent",
                "type" => "error",
                "typeCode" => 1,
                "message" => "Anchor element found with a valid href attribute, but no link content has been supplied.",
                "context" => "<a class=\"site-title active\" rel=\"author\" href=\"/\">\n        <svg version=\"1.0\" xml...</a>",
                "selector" => "html > body > header > div > nav > a",
                "runner" => "htmlcs",
                "runnerExtras" => {}
              }
            ]
          }

        head_report.errors = 1
        head_report.urls = {
          "https://gitlab.com" =>
            [
              {
                "code" => "WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent",
                "type" => "error",
                "typeCode" => 1,
                "message" => "Anchor element found with a valid href attribute, but no link content has been supplied.",
                "context" => "<a class=\"social-icon\" target=\"_blank\" href=\"https://gitlab.com\" rel=\"nofollow noopener noreferrer\">\n        <svg xmlns=\"http://www...</a>",
                "selector" => "html > body > header > div > nav > a",
                "runner" => "htmlcs",
                "runnerExtras" => {}
              }
            ]
          }
      end

      it 'contains correct compared accessibility report details' do
        expect(subject[:status]).to eq(Gitlab::Ci::Reports::AccessibilityReportsComparer::STATUS_FAILED)
        expect(subject[:new_errors].first).to include(:code, :type, :type_code, :message, :context, :selector, :runner, :runner_extras)
        expect(subject[:resolved_errors]).to be_empty
        expect(subject[:existing_errors].first).to include(:code, :type, :type_code, :message, :context, :selector, :runner, :runner_extras)
        expect(subject[:summary]).to include(:total, :resolved, :errored)
      end
    end
  end
end
