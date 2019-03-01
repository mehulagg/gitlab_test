# frozen_string_literal: true

require 'spec_helper'

describe ::Gitlab::Ci::Build::Image do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:job) { create(:ci_build, pipeline: pipeline, options: options ) }

  subject { described_class.new(job.options[:image], job) }

  context 'when the job is not from web ide' do
    let(:pipeline) { create(:ee_ci_pipeline, project: project, user: user) }

    context 'when image is defined as string' do
      let(:options) { { image: 'ruby' } }

      it 'does not populate the ports' do
        expect(job.pipeline).not_to receive(:webide?)
        expect(subject.ports).to be_nil
      end
    end

    context 'when image is defined as hash' do
      let(:options) { { image: { name: 'ruby', ports: [80] } } }

      it 'does not populate the ports' do
        expect(job.pipeline).to receive(:webide?).and_call_original
        expect(subject.ports).to be_nil
      end
    end
  end

  context 'when the job is from web ide' do
    let(:pipeline) { create(:ee_ci_pipeline, :webide, project: project, user: user) }

    context 'when image is defined as string' do
      let(:options) { { image: 'ruby' } }

      it 'does not populate the ports' do
        expect(job.pipeline).not_to receive(:webide?)
        expect(subject.ports).to be_nil
      end
    end

    context 'when image is defined as hash' do
      let(:options) { { image: { name: 'ruby', ports: [80] } } }

      it 'populates the ports' do
        expect(job.pipeline).to receive(:webide?).and_call_original
        expect(subject.ports).not_to be_nil

        port = subject.ports.first
        expect(port.external_port).to eq 80
        expect(port.internal_port).to eq 80
        expect(port.insecure).to eq false
        expect(port.name).to eq 'default_port'
      end
    end
  end
end
