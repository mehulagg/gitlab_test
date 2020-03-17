# frozen_string_literal: true

require 'spec_helper'

describe Ci::PipelineTestReportsFinder do
  let(:pipeline) { create(:ci_pipeline, :with_test_reports) }

  subject { described_class.new(pipeline).execute(params) }

  describe "#execute" do
    context 'when the scope is nil' do
      let(:params) { { scope: nil } }

      it 'selects all test reports' do
        expect(subject.test_suites.count).to be(1)
      end
    end
  end
end
