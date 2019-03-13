# frozen_string_literal: true
require 'spec_helper'

describe ProtectedEnvironments::CreateService, '#execute' do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:maintainer_access) { Gitlab::Access::MAINTAINER }

  let(:params) do
    attributes_for(:protected_environment,
                   deploy_access_levels_attributes: [{ access_level: maintainer_access }])
  end

  subject { described_class.new(project, user, params).execute }

  context 'with valid params' do
    shared_examples 'succesfully creates protected environment' do
      it { is_expected.to be_truthy }

      it 'creates a record on ProtectedEnvironment' do
        expect { subject }.to change(ProtectedEnvironment, :count).by(1)
      end

      it 'creates a record on ProtectedEnvironment record' do
        expect { subject }.to change(ProtectedEnvironment::DeployAccessLevel, :count).by(1)
      end
    end

    include_examples 'succesfully creates protected environment'

    context 'when there is a feature flag' do
      let!(:feature_flag) do
        create(:operations_feature_flag, project: project,
               scopes_attributes: [{ environment_scope: '*', active: true },
                                   { environment_scope: 'review/*', active: false }])
      end

      include_examples 'succesfully creates protected environment'

      it 'creates scope for feature flag' do
        expect do
          subject
        end.to change { feature_flag.reload.scopes.find_by_environment_scope('production') }.from(nil).to(be)
      end

      it 'sets active for production scope base on * scope' do
        subject

        expect(feature_flag.reload.scopes.find_by_environment_scope('production').active).to eq(true)
      end

      context 'when creating review/my-branch protected environment' do
        let(:params) do
          attributes_for(:protected_environment,
                         deploy_access_levels_attributes: [{ access_level: maintainer_access }],
                         name: 'review/my-branch')
        end

        it 'sets active bases on review/* scope' do
          subject

          expect(feature_flag.reload.scopes.find_by_environment_scope('review/my-branch').active).to eq(false)
        end
      end

      context 'when feature flag permissions are disabled' do
        before do
          stub_feature_flags(feature_flag_permissions: false)
        end

        include_examples 'succesfully creates protected environment'

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

        include_examples 'succesfully creates protected environment'

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

    it 'returns a non-persisted Protected Environment record' do
      expect(subject.persisted?).to be_falsy
    end
  end
end
