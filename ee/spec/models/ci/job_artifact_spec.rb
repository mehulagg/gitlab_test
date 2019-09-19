# frozen_string_literal: true

require 'spec_helper'

describe Ci::JobArtifact do
  include EE::GeoHelpers

  describe '.security_reports' do
    subject { described_class.security_reports }

    context 'when there is a security report' do
      let!(:artifact) { create(:ee_ci_job_artifact, :sast) }

      it { is_expected.to eq([artifact]) }
    end

    context 'when there are no security reports' do
      let!(:artifact) { create(:ci_job_artifact, :archive) }

      it { is_expected.to be_empty }
    end
  end
end
