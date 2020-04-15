# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::AccessibilityReportsComparer do
  let(:comparer) { described_class.new(base_reports, head_reports) }
  let(:base_reports) { Gitlab::Ci::Reports::AccessibilityReports.new }
  let(:head_reports) { Gitlab::Ci::Reports::AccessibilityReports.new }

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
end
