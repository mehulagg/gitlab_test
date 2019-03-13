# frozen_string_literal: true
require 'spec_helper'

describe ProtectedEnvironments::UpdateService, '#execute' do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:maintainer_access) { Gitlab::Access::MAINTAINER }
  let(:protected_environment) { create(:protected_environment, project: project) }
  let(:deploy_access_level) { protected_environment.deploy_access_levels.first }

  let(:params) do
    {
      deploy_access_levels_attributes: [
        { id: deploy_access_level.id, access_level: Gitlab::Access::DEVELOPER },
        { access_level: maintainer_access }
      ]
    }
  end

  subject { described_class.new(project, user, params).execute(protected_environment) }

  before do
    deploy_access_level
  end

  context 'with valid params' do
    shared_examples 'succesfully updates protected environment' do
      it { is_expected.to be_truthy }

      it 'updates the deploy access levels' do
        expect do
          subject
        end.to change { ProtectedEnvironment::DeployAccessLevel.count }.from(1).to(2)
      end
    end

    include_examples 'succesfully updates protected environment'

    context 'when there is a feature flag' do
      let!(:feature_flag) { create(:operations_feature_flag, project: project) }

      include_examples 'succesfully updates protected environment'

      it 'creates scope for feature flag' do
        expect do
          subject
        end.to change { feature_flag.reload.scopes.find_by_environment_scope('production') }.from(nil).to(be)
      end

      context 'when feature flag permissions are disabled' do
        before do
          stub_feature_flags(feature_flag_permissions: false)
        end

        include_examples 'succesfully updates protected environment'

        it 'does not create scope for feature flag' do
          expect do
            subject
          end.not_to change { feature_flag.reload.scopes.find_by_environment_scope('production') }.from(nil)
        end
      end

      context 'when feature flag already has scope' do
        before do
          feature_flag.scopes.create!(environment_scope: 'production', active: true)
        end

        include_examples 'succesfully updates protected environment'

        it 'does not create feature flag scope' do
          expect do
            subject
          end.not_to change { feature_flag.reload.scopes.where(environment_scope: 'production').count }.from(1)
        end
      end
    end
  end

  context 'with invalid params' do
    let(:maintainer_access) { 0 }

    it { is_expected.to be_falsy }

    it 'does not update the deploy access levels' do
      expect do
        subject
      end.not_to change { ProtectedEnvironment::DeployAccessLevel.count }
    end
  end
end
