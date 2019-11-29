# frozen_string_literal: true

require 'spec_helper'

describe Ci::ResourceGroups::ReleaseResourceFromBuildService do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let(:service) { described_class.new(project, user) }

  describe '#execute' do
    subject { service.execute(build) }

    let(:resource_group) { create(:ci_resource_group, project: project) }
    let(:build) { create(:ci_build, :success, project: project, user: user, resource_group: resource_group) }

    context 'when build retains a resource' do
      before do
        resource_group.retain_resource_for(build)
      end

      it 'releases a resource' do
        is_expected.to eq(status: :success)

        expect(build.reset).not_to be_retains_resource
      end

      context 'when there is a waiting build' do
        let!(:another_build) { create(:ci_build, :waiting_for_resource, project: project, user: user, resource_group: resource_group) }

        it 'retains a resource for the next build' do
          expect_next_instance_of(::Ci::ResourceGroups::RetainResourceForBuildService, project, user) do |service|
            expect(service).to receive(:execute).with(another_build).and_call_original
          end

          is_expected.to eq(status: :success, build: another_build)

          expect(another_build).to be_retains_resource
        end

        context 'when failed to retain a resouce for the next build' do
          before do
            allow_next_instance_of(::Ci::ResourceGroups::RetainResourceForBuildService, project, user) do |service|
              allow(service).to receive(:execute).with(another_build) { { status: :error, message: 'Unknown Failure' } }
            end
          end

          it 'returns an error' do
            is_expected.to eq(status: :error, message: "Failed to retain a resource for the next build. Unknown Failure")
          end
        end
      end

      context 'when failed to release a resource' do
        before do
          allow(build.resource_group).to receive(:release_resource_from) { false }
        end

        it 'returns an error' do
          is_expected.to eq(status: :error, message: 'Failed to release a resource')
        end
      end
    end

    context 'when build does not retain a resource' do
      it 'returns an error' do
        is_expected.to eq(status: :error, message: 'This build does not retain a resource')
      end
    end
  end
end
