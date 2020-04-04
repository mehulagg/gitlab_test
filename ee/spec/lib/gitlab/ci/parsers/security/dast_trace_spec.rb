# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::Security::DastTrace do
  describe '#line_number' do
    let(:build) { create(:ci_build) }
    let(:parser) { described_class.new }

    subject { parser.line_number(build.trace) }

    context 'the trace is empty' do
      it { is_expected.to be(nil) }
    end

    context 'the trace does not include the scanned resources' do
      before do
        create(:ci_job_artifact, :trace, job: build)
      end

      it { is_expected.to be(nil) }
    end

    context 'the trace includes the scanned resources' do
      before do
        create(:ee_ci_job_artifact, :dast_trace, job: build)
      end
      it { is_expected.to be(350) }
    end
  end
end
