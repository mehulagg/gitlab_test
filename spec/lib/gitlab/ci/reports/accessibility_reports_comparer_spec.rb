# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::AccessibilityReportsComparer do
  let(:comparer) { described_class.new(base_reports, head_reports) }
  let(:base_reports) { Gitlab::Ci::Reports::AccessibilityReports.new }
  let(:head_reports) { Gitlab::Ci::Reports::AccessibilityReports.new }

  describe '#status' do
    subject { comparer.status }

    context 'when head report has an error' do
      before do
        head_reports.errors = 1
      end

      it 'returns status failed' do
        expect(subject).to eq(Gitlab::Ci::Reports::AccessibilityReportsComparer::STATUS_FAILED)
      end
    end

    context 'when head reports have an accessibility report and head has no errors' do
      before do
        head_reports.errors = 0
      end

      it 'returns status success' do
        expect(subject).to eq(Gitlab::Ci::Reports::AccessibilityReportsComparer::STATUS_SUCCESS)
      end
    end
  end

  describe '#added' do
    subject { comparer.added }

    context 'when base reports have an accessibility report and head has more errors' do
      before do
        base_reports.errors = 1
        head_reports.errors = 3
      end

      it 'returns the number of new errors' do
        expect(subject).to eq(2)
      end
    end

    context 'when base reports have an accessibility report and head has no errors' do
      before do
        base_reports.errors = 1
        head_reports.errors = 0
      end

      it 'returns the number of new errors' do
        expect(subject).to eq(0)
      end
    end

    context 'when base reports have an accessibility report and head has the same number of errors' do
      before do
        base_reports.errors = 1
        head_reports.errors = 1
      end

      it 'returns the number of new errors' do
        expect(subject).to eq(0)
      end
    end

    context 'when base reports does not have an accessibility report and head has errors' do
      before do
        head_reports.errors = 1
      end

      it 'returns the number of new errors' do
        expect(subject).to eq(1)
      end
    end
  end

  describe '#new_errors' do
    subject { comparer.new_errors }

    context 'when base reports have an accessibility report and head has more errors' do
      before do
        base_reports.urls = {
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

        head_reports.urls = {
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
              },
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

      it 'returns diff between base and head reports' do
        expect(subject.size).to eq(1)
        expect(subject.first["context"]).to include("nofollow noopener noreferrer")
      end
    end

    context 'when base reports have an accessibility report and head has no errors' do
      before do
        base_reports.urls = {
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

        head_reports.urls = {
          "https://gitlab.com" => []
        }
      end

      it 'returns diff between base and head reports' do
        expect(subject.size).to eq(1)
        expect(subject.first["message"]).to include("no link content has been supplied")
      end
    end

    context 'when base reports does not have an accessibility report and head has errors' do
      before do
        head_reports.urls = {
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
      end

      it 'returns an empty diff' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#resolved_errors' do
    subject { comparer.resolved_errors }

    context 'when base report has errors and head has the same errors' do
      before do
        base_reports.urls = {
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

        head_reports.urls = {
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
              },
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

      it 'returns an empty array' do
        expect(subject).to be_empty
      end
    end

    context 'when base reports has an error and head has a different error' do
      before do
        base_reports.urls = {
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

        head_reports.urls = {
          "https://gitlab.com" => [
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

      it 'returns the resolved error' do
        expect(subject.size).to eq(1)
      end
    end

    context 'when base reports does not have errors head has errors' do
      before do
        head_reports.urls = {
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
      end

      it 'returns an empty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#existing_errors' do
    subject { comparer.existing_errors }

    context 'when base report has errors and head has no errors' do
      before do
        base_reports.urls = {
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

        head_reports.urls = {
          "https://gitlab.com" => []
        }
      end

      it 'returns existing errors' do
        expect(subject.size).to eq(1)
      end
    end

    context 'when base reports does not have errors and head has errors' do
      before do
        base_reports.urls = {
          "https://gitlab.com" => []
          }

        head_reports.urls = {
          "https://gitlab.com" => [
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

      it 'returns the resolved error' do
        expect(subject).to be_empty
      end
    end
  end
end
