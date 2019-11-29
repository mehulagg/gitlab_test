# frozen_string_literal: true

require 'spec_helper'

describe Ci::ResourceGroups::ReleaseResourceFromBuildWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject { worker.perform(build_id) }

    context 'when build exists' do
      let(:build) { create(:ci_build) }
      let(:build_id) { build.id }

      it 'executes ReleaseResourceFromBuildService' do
        expect_next_instance_of(::Ci::ResourceGroups::ReleaseResourceFromBuildService, build.project, build.user) do |service|
          expect(service).to receive(:execute).with(build)
        end

        subject
      end
    end

    context 'when build does not exist' do
      let(:build_id) { 123 }

      it 'does not execute ReleaseResourceFromBuildService' do
        expect(::Ci::ResourceGroups::ReleaseResourceFromBuildService).not_to receive(:new)

        subject
      end
    end
  end
end
