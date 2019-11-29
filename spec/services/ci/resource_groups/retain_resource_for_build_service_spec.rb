# frozen_string_literal: true

require 'spec_helper'

describe Ci::ResourceGroups::RetainResourceForBuildService do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let(:service) { described_class.new(project, user) }

  describe '#execute' do
    subject { service.execute(build) }

    context 'when build requires resource' do
      let(:resource_group) { create(:ci_resource_group, project: project) }
      let(:build) { create(:ci_build, :waiting_for_resource, project: project, user: user, resource_group: resource_group) }

      context 'when there is an available resource' do
        it 'retains a resouce and makes build pending' do
          is_expected.to eq(status: :success)

          expect(build).to be_retains_resource
          expect(build).to be_pending
        end

        context 'when failed to enqueue the build' do
          before do
            allow(build).to receive(:enqueue) { false }
          end

          it 'returns an error' do
            is_expected.to eq(status: :error, message: 'Failed to enqueue')

            expect(build).to be_retains_resource
            expect(build).to be_waiting_for_resource
          end
        end

        context 'when the build has already retained a resource' do
          before do
            resource_group.retain_resource_for(build)
            build.update_column(:status, :pending)
          end

          it 'returns an error' do
            is_expected.to eq(status: :error, message: 'This build does not require a resource')

            expect(build).to be_retains_resource
            expect(build).to be_pending
          end
        end
      end

      context 'when there are no available resources' do
        before do
          resource_group.retain_resource_for(create(:ci_build))
        end

        it 'failed to retain a resouce' do
          is_expected.to eq(status: :error, message: 'Failed to retain a resource')

          expect(build).to be_requires_resource
          expect(build).to be_waiting_for_resource
        end
      end
    end
  end
end
