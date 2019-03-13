# frozen_string_literal: true

require 'spec_helper'

describe FeatureFlags::DestroyService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let!(:feature_flag) { create(:operations_feature_flag) }

  describe '#execute' do
    subject { described_class.new(project, user).execute(feature_flag) }
    let(:audit_event_message) { AuditEvent.last.present.action }

    shared_examples 'destroys successfully' do
      it 'returns status success' do
        expect(subject[:status]).to eq(:success)
      end

      it 'destroys feature flag' do
        expect { subject }.to change { Operations::FeatureFlag.count }.by(-1)
      end
    end

    include_examples 'destroys successfully'

    it 'creates audit log' do
      expect { subject }.to change { AuditEvent.count }.by(1)
      expect(audit_event_message).to eq("Deleted feature flag <strong>#{feature_flag.name.tr('_', ' ')}</strong>.")
    end

    context 'when feature flag can not be destroyed' do
      before do
        allow(feature_flag).to receive(:destroy).and_return(false)
      end

      it 'returns status error' do
        expect(subject[:status]).to eq(:error)
      end

      it 'does not create audit log' do
        expect { subject }.not_to change { AuditEvent.count }
      end
    end

    context 'when feature flag contain scope for protected environment' do
      before do
        stub_licensed_features(protected_environments: true)
        create(:operations_feature_flag_scope, feature_flag: feature_flag, environment_scope: 'production')
      end

      context 'when user does not have access to environment' do
        before do
          create(:protected_environment, project: project, name: 'production')
        end

        it 'returns error' do
          expect(subject[:status]).to eq(:error)
          expect(subject[:message]).to eq("You don't have persmissions to change feature flag in production environment.")
        end

        context 'when feature flag permissions are disabled' do
          before do
            stub_feature_flags(feature_flag_permissions: false)
          end

          include_examples 'destroys successfully'
        end

        context 'when protected environmens are disabled' do
          before do
            stub_licensed_features(protected_environments: false)
          end

          include_examples 'destroys successfully'
        end
      end

      context 'when user has access to environment' do
        before do
          create(:protected_environment, project: project, name: 'production', authorize_user_to_deploy: user)
        end

        include_examples 'destroys successfully'
      end
    end
  end
end
