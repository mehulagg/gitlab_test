# frozen_string_literal: true

require 'spec_helper'

describe FeatureFlags::UpdateService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:feature_flag) { create(:operations_feature_flag) }

  describe '#execute' do
    subject { described_class.new(project, user, params).execute(feature_flag) }
    let(:params) { { name: 'new_name' } }
    let(:audit_event_message) do
      AuditEvent.last.present.action
    end

    it 'returns success status' do
      expect(subject[:status]).to eq(:success)
    end

    it 'creates audit event with correct message' do
      name_was = feature_flag.name

      expect { subject }.to change { AuditEvent.count }.by(1)
      expect(audit_event_message).to(
        eq("Updated feature flag <strong>new name</strong>. "\
           "Updated name from <strong>\"#{name_was.tr('_', ' ')}\"</strong> "\
           "to <strong>\"new name\"</strong>.")
      )
    end

    context 'with invalid params' do
      let(:params) { { name: nil } }

      it 'returns error status' do
        expect(subject[:status]).to eq(:error)
      end

      it 'returns error messages' do
        expect(subject[:message]).to include("Name can't be blank")
      end

      it 'does not create audit event' do
        expect { subject }.not_to change { AuditEvent.count }
      end
    end

    context 'when nothing is changed' do
      let(:params) { {} }

      it 'returns success status' do
        expect(subject[:status]).to eq(:success)
      end

      it 'does not create audit event' do
        expect { subject }.not_to change { AuditEvent.count }
      end
    end

    context 'description is being changed' do
      let(:params) { { description: 'new description' } }

      it 'creates audit event with changed description' do
        expect { subject }.to change { AuditEvent.count }.by(1)
        expect(audit_event_message).to(
          include("Updated description from <strong>\"\"</strong>"\
                  " to <strong>\"new description\"</strong>.")
        )
      end
    end

    context 'when active state is changed' do
      let(:changed_scope) { feature_flag.scopes.create!(environment_scope: 'review', active: true) }
      let(:params) do
        {
          scopes_attributes: [{ id: changed_scope.id, active: false }]
        }
      end

      it 'creates audit event about changing active stae' do
        expect { subject }.to change { AuditEvent.count }.by(1)
        expect(audit_event_message).to(
          include("Updated rule <strong>review</strong> active state "\
                  "from <strong>true</strong> to <strong>false</strong>.")
        )
      end

      context 'when scope is protected' do
        before do
          stub_licensed_features(protected_environments: true)
        end

        shared_examples 'updates successfully' do
          it 'returns success' do
            expect(subject[:status]).to eq(:success)
          end

          it 'updates scope' do
            expect do
              subject
            end.to change { changed_scope.reload.active }.from(true).to(false)
          end
        end

        context 'when user does not have access to environment' do
          before do
            create(:protected_environment, project: project, name: changed_scope.environment_scope)
          end

          it 'returns error' do
            expect(subject[:status]).to eq(:error)
            expect(subject[:message]).to eq("You don't have persmissions to change feature flag in review environment.")
          end

          it 'does not update scope' do
            expect do
              subject
            end.not_to change { changed_scope.reload.active }.from(true)
          end

          context 'when feature flag permissions are disabled' do
            before do
              stub_feature_flags(feature_flag_permissions: false)
            end

            include_examples 'updates successfully'
          end

          context 'when protected environmens are disabled' do
            before do
              stub_licensed_features(protected_environments: false)
            end

            include_examples 'updates successfully'
          end
        end

        context 'when user has access to environment' do
          before do
            create(:protected_environment, project: project, name: changed_scope.environment_scope, authorize_user_to_deploy: user)
          end

          include_examples 'updates successfully'
        end
      end
    end

    context 'when scope is renamed' do
      let(:changed_scope) { feature_flag.scopes.create!(environment_scope: 'review', active: true) }
      let(:params) do
        {
          scopes_attributes: [{ id: changed_scope.id, environment_scope: 'staging' }]
        }
      end

      it 'creates audit event with changed name' do
        expect { subject }.to change { AuditEvent.count }.by(1)
        expect(audit_event_message).to(
          include("Updated rule <strong>staging</strong> environment scope "\
                  "from <strong>review</strong> to <strong>staging</strong>.")
        )
      end

      context 'when scope can not be updated' do
        let(:params) do
          {
            scopes_attributes: [{ id: changed_scope.id, environment_scope: '' }]
          }
        end

        it 'returns error status' do
          expect(subject[:status]).to eq(:error)
        end

        it 'returns error messages' do
          expect(subject[:message]).to include("Scopes environment scope can't be blank")
        end

        it 'does not create audit event' do
          expect { subject }.not_to change { AuditEvent.count }
        end
      end

      context 'when scope is protected' do
        before do
          stub_licensed_features(protected_environments: true)
        end

        shared_examples 'updates successfully' do
          it 'returns success' do
            expect(subject[:status]).to eq(:success)
          end

          it 'updates scope' do
            expect do
              subject
            end.to change { changed_scope.reload.environment_scope }.from('review').to('staging')
          end
        end

        context 'when user does not have access to environment' do
          before do
            create(:protected_environment, project: project, name: changed_scope.environment_scope)
          end

          it 'returns error' do
            expect(subject[:status]).to eq(:error)
            expect(subject[:message]).to eq("You don't have persmissions to change feature flag in review environment.")
          end

          it 'does not update scope' do
            expect do
              subject
            end.not_to change { changed_scope.reload.environment_scope }.from('review')
          end

          context 'when feature flag permissions are disabled' do
            before do
              stub_feature_flags(feature_flag_permissions: false)
            end

            include_examples 'updates successfully'
          end

          context 'when protected environmens are disabled' do
            before do
              stub_licensed_features(protected_environments: false)
            end

            include_examples 'updates successfully'
          end
        end

        context 'when user has access to environment' do
          before do
            create(:protected_environment, project: project, name: changed_scope.environment_scope, authorize_user_to_deploy: user)
          end

          include_examples 'updates successfully'
        end
      end
    end

    context 'when scope is deleted' do
      let(:deleted_scope) { feature_flag.scopes.create!(environment_scope: 'review', active: true) }
      let(:params) do
        {
          scopes_attributes: [{ id: deleted_scope.id, '_destroy': true }]
        }
      end

      it 'creates audit event with deleted scope' do
        expect { subject }.to change { AuditEvent.count }.by(1)
        expect(audit_event_message).to include("Deleted rule <strong>review</strong>.")
      end

      context 'when scope can not be deleted' do
        RSpec::Matchers.define_negated_matcher :not_change, :change

        before do
          allow(deleted_scope).to receive(:destroy).and_return(false)
        end

        it 'does not create audit event' do
          expect do
            subject
          end.to not_change { AuditEvent.count }.and raise_error(ActiveRecord::RecordNotDestroyed)
        end
      end

      context 'when scope is protected' do
        before do
          stub_licensed_features(protected_environments: true)
        end

        shared_examples 'updates successfully' do
          it 'returns success' do
            expect(subject[:status]).to eq(:success)
          end

          it 'deletes scope' do
            subject

            expect(Operations::FeatureFlagScope.find_by_id(deleted_scope.id)).to be_nil
          end
        end

        context 'when user does not have access to environment' do
          before do
            create(:protected_environment, project: project, name: deleted_scope.environment_scope)
          end

          it 'returns error' do
            expect(subject[:status]).to eq(:error)
            expect(subject[:message]).to eq("You don't have persmissions to change feature flag in review environment.")
          end

          it 'does not delete scope' do
            subject

            expect(Operations::FeatureFlagScope.find_by_id(deleted_scope.id)).to be_present
          end

          context 'when feature flag permissions are disabled' do
            before do
              stub_feature_flags(feature_flag_permissions: false)
            end

            include_examples 'updates successfully'
          end

          context 'when protected environmens are disabled' do
            before do
              stub_licensed_features(protected_environments: false)
            end

            include_examples 'updates successfully'
          end
        end

        context 'when user has access to environment' do
          before do
            create(:protected_environment, project: project, name: deleted_scope.environment_scope, authorize_user_to_deploy: user)
          end

          include_examples 'updates successfully'
        end
      end
    end

    context 'when new scope is being added' do
      let(:new_environment_scope) { 'review' }
      let(:params) do
        {
          scopes_attributes: [{ environment_scope: new_environment_scope, active: true }]
        }
      end

      shared_examples 'check uniqueness and adds new scope' do
        it 'creates new scope' do
          expect(feature_flag.scopes.find_by_environment_scope(new_environment_scope)).to be_nil

          subject

          expect(feature_flag.scopes.find_by_environment_scope(new_environment_scope)).to be
        end

        it 'creates audit event with new scope' do
          subject

          expect(audit_event_message).to(
            include("Created rule <strong>review</strong> and set it as <strong>active</strong>.")
          )
        end

        context 'when scope already exists' do
          before do
            feature_flag.scopes.create!(environment_scope: new_environment_scope, active: true)
          end

          it 'returns validation error' do
            expect(subject[:status]).to eq(:error)
            expect(subject[:message]).to eq(["Scopes environment scope (#{new_environment_scope}) has already been taken"])
          end
        end
      end

      include_examples 'check uniqueness and adds new scope'

      context 'when scope can not be created' do
        let(:new_environment_scope) { '' }

        it 'returns error status' do
          expect(subject[:status]).to eq(:error)
        end

        it 'returns error messages' do
          expect(subject[:message]).to include("Scopes environment scope can't be blank")
        end

        it 'does not create audit event' do
          expect { subject }.not_to change { AuditEvent.count }
        end
      end

      context 'when scope is protected' do
        before do
          stub_licensed_features(protected_environments: true)
        end

        context 'when user does not have access to environment' do
          before do
            create(:protected_environment, project: project, name: new_environment_scope)
          end

          include_examples 'check uniqueness and adds new scope'
        end

        context 'when user has access to environment' do
          before do
            create(:protected_environment, project: project, name: new_environment_scope, authorize_user_to_deploy: user)
          end

          include_examples 'check uniqueness and adds new scope'
        end
      end
    end
  end
end
