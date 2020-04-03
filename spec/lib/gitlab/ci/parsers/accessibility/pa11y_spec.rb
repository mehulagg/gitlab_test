# frozen_string_literal: true

require 'fast_spec_helper'

describe Gitlab::Ci::Parsers::Accessibility::Pa11y do
  describe '#parse!' do
    subject { described_class.new.parse!(pa11y, accessibility_report) }

    let(:accessibility_report) { Gitlab::Ci::Reports::AccessibilityReports.new }

    context "when data is pa11y style JSON" do
      context "when there is no URLs provided" do
        let(:pa11y) do
          {
            "total": 1,
            "passes": 0,
            "errors": 0,
            "results": {
              "": [
                {
                  "message": "Protocol error (Page.navigate): Cannot navigate to invalid URL"
                }
              ]
            }
          }.to_json
        end

        it "returns an accessibility report" do
          expect { subject }.not_to raise_error

          expect(accessibility_report.urls.keys).to eq([""])
          expect(accessibility_report.errors).to eq(0)
          expect(accessibility_report.passes).to eq(0)
          expect(accessibility_report.total).to eq(1)
        end
      end

      context "when there are no errors" do
        let(:pa11y) do
          {
            "total": 1,
            "passes": 1,
            "errors": 0,
            "results": {
              "http://pa11y.org/": []
            }
          }.to_json
        end

        it "returns an accessibility report" do
          expect { subject }.not_to raise_error

          expect(accessibility_report.urls.keys.size).to eq(1)
          expect(accessibility_report.errors).to eq(0)
          expect(accessibility_report.passes).to eq(1)
          expect(accessibility_report.total).to eq(1)
        end
      end

      context "when there are errors" do
        let(:pa11y) do
          {
            "total": 1,
            "passes": 0,
            "errors": 3,
            "results": {
              "https://www.google.com/": [
                {
                  "code": "WCAG2AA.Principle1.Guideline1_3.1_3_1.H49.Center",
                  "type": "error",
                  "typeCode": 1,
                  "message": "Presentational markup used that has become obsolete in HTML5.",
                  "context": "<center><br clear=\"all\" id=\"lgpd\"><div ...</center>",
                  "selector": "html > body > center",
                  "runner": "htmlcs",
                  "runnerExtras": {}
                },
                {
                  "code": "WCAG2AA.Principle1.Guideline1_3.1_3_1.H49.AlignAttr",
                  "type": "error",
                  "typeCode": 1,
                  "message": "Align attributes .",
                  "context": "<td align=\"center\" nowrap=\"\"><input name=\"ie\" value=\"ISO-885...</td>",
                  "selector": "html > body > center > form > table > tbody > tr > td:nth-child(2)",
                  "runner": "htmlcs",
                  "runnerExtras": {}
                },
                {
                  "code": "WCAG2AA.Principle1.Guideline1_3.1_3_1.H49.AlignAttr",
                  "type": "error",
                  "typeCode": 1,
                  "message": "Align attributes .",
                  "context": "<td class=\"fl sblc\" align=\"left\" nowrap=\"\" width=\"25%\"><a href=\"/advanced_search?hl=en...</td>",
                  "selector": "html > body > center > form > table > tbody > tr > td:nth-child(3)",
                  "runner": "htmlcs",
                  "runnerExtras": {}
                }
              ]
            }
          }.to_json
        end

        it "returns an accessibility report" do
          expect { subject }.not_to raise_error

          expect(accessibility_report.errors).to eq(3)
          expect(accessibility_report.passes).to eq(0)
          expect(accessibility_report.total).to eq(1)
        end
      end
    end
  end
end
