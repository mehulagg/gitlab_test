# frozen_string_literal: true

require 'spec_helper'

describe FeatureFlags::CreateService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  describe '#execute' do
    subject do
      described_class.new(project, user, params).execute
    end
    let(:feature_flag) { subject[:feature_flag] }

    context 'when feature flag can not be created' do
      let(:params) { {} }

      it 'returns status error' do
        expect(subject[:status]).to eq(:error)
      end

      it 'returns validation errors' do
        expect(subject[:message]).to include("Name can't be blank")
      end

      it 'does not create audit log' do
        expect { subject }.not_to change { AuditEvent.count }
      end
    end

    context 'when feature flag is saved correctly' do
      let(:params) do
        {
          name: 'feature_flag',
          description: 'description',
          scopes_attributes: [{ environment_scope: '*', active: true },
                              { environment_scope: 'production', active: false },
                              { environment_scope: 'review/*', active: false }]
        }
      end

      shared_examples 'successfully creates feature flag' do
        it 'returns status success' do
          expect(subject[:status]).to eq(:success)
        end

        it 'creates feature flag' do
          expect { subject }.to change { Operations::FeatureFlag.count }.by(1)
        end
      end

      include_examples 'successfully creates feature flag'

      it 'creates audit event' do
        expected_message = "Created feature flag <strong>feature flag</strong> "\
                           "with description <strong>\"description\"</strong>. "\
                           "Created rule <strong>*</strong> and set it as <strong>active</strong>. "\
                           "Created rule <strong>production</strong> and set it as <strong>inactive</strong>. "\
                           "Created rule <strong>review/*</strong> and set it as <strong>inactive</strong>."

        expect { subject }.to change { AuditEvent.count }.by(1)
        expect(AuditEvent.last.present.action).to eq(expected_message)
      end

      context 'when protected environmens are enabled' do
        before do
          stub_licensed_features(protected_environments: true)
        end

        include_examples 'successfully creates feature flag'

        context 'when there are protected environments' do
          before do
            create(:protected_environment, project: project)
            create(:protected_environment, :staging, project: project)
            create(:protected_environment, project: project, name: 'review/my-branch')
          end

          include_examples 'successfully creates feature flag'

          it 'creates scopes for protected environments' do
            expect(feature_flag.scopes.find_by_environment_scope('production')).to be
            expect(feature_flag.scopes.find_by_environment_scope('staging')).to be
            expect(feature_flag.scopes.find_by_environment_scope('review/my-branch')).to be
          end

          it 'use * as reference for active value for not provided scope' do
            expect(feature_flag.scopes.find_by_environment_scope('staging').active).to eq(true)
          end

          it 'use review/* as reference for active value for review/my-branch' do
            expect(feature_flag.scopes.find_by_environment_scope('review/my-branch').active).to eq(false)
          end

          it 'use active value provided through params' do
            expect(feature_flag.scopes.find_by_environment_scope('production').active).to eq(false)
          end

          context 'when feature flag permissions are disabled' do
            before do
              stub_feature_flags(feature_flag_permissions: false)
            end

            include_examples 'successfully creates feature flag'

            it 'does not create scope for protected environment unless it passed in params' do
              expect(feature_flag.scopes.find_by_environment_scope('production')).to be
              expect(feature_flag.scopes.find_by_environment_scope('staging')).to be_nil
            end
          end
        end
      end
    end
  end
end
