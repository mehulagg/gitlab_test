# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Security::CredentialsController do
  let_it_be(:group_with_managed_accounts) { create(:group_with_managed_accounts, :private) }
  let_it_be(:managed_users) { create_list(:user, 2, :group_managed, managing_group: group_with_managed_accounts) }
  let_it_be(:owner) { managed_users.first }
  let_it_be(:maintainer) { managed_users.last }
  let_it_be(:group_id) { group_with_managed_accounts.to_param }

  before do
    allow_next_instance_of(Gitlab::Auth::GroupSaml::SsoEnforcer) do |sso_enforcer|
      allow(sso_enforcer).to receive(:active_session?).and_return(true)
    end

    group_with_managed_accounts.add_owner(owner)
    group_with_managed_accounts.add_maintainer(maintainer)

    sign_in(owner)
  end

  describe 'GET #index' do
    let_it_be(:filter) {}

    subject { get :index, params: { group_id: group_id.to_param, filter: filter } }

    context 'when `credentials_inventory` feature is enabled' do
      before do
        stub_licensed_features(credentials_inventory: true, group_saml: true)
      end

      context 'for a group that enforces group managed accounts' do
        context 'for a user with access to view credentials inventory' do
          it 'responds with 200' do
            subject

            expect(response).to have_gitlab_http_status(:ok)
          end

          context 'filtering by type of credential' do
            before do
              managed_users.each do |user|
                create(:personal_access_token, user: user)
              end
            end

            shared_examples_for 'filtering by `personal_access_tokens`' do
              it do
                subject

                expect(assigns(:credentials)).to match_array(PersonalAccessToken.where(user: managed_users))
              end
            end

            context 'no credential type specified' do
              let_it_be(:filter) { nil }

              it_behaves_like 'filtering by `personal_access_tokens`'
            end

            context 'non-existent credential type specified' do
              let_it_be(:filter) { 'non_existent_credential_type' }

              it_behaves_like 'filtering by `personal_access_tokens`'
            end

            context 'credential type specified as `personal_access_tokens`' do
              let_it_be(:filter) { 'personal_access_tokens' }

              it_behaves_like 'filtering by `personal_access_tokens`'
            end

            context 'user scope' do
              it 'does not show the credentials of a user outside the group' do
                personal_access_token = create(:personal_access_token, user: create(:user))

                subject

                expect(assigns(:credentials)).not_to include(personal_access_token)
              end
            end

            context 'credential type specified as `ssh_keys`' do
              let_it_be(:filter) { 'ssh_keys' }

              before do
                managed_users.each do |user|
                  create(:personal_key, user: user)
                end
              end

              it 'filters by ssh keys' do
                subject

                expect(assigns(:credentials)).to match_array(Key.regular_keys.where(user: managed_users))
              end
            end
          end

          context 'for a user without access to view credentials inventory' do
            before do
              sign_in(maintainer)
            end

            it 'responds with 404' do
              subject

              expect(response).to have_gitlab_http_status(:not_found)
            end
          end
        end
      end

      context 'for a group that does not enforce group managed accounts' do
        let_it_be(:group_id) { create(:group).to_param }

        it 'responds with 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when `credentials_inventory` feature is disabled' do
      before do
        stub_licensed_features(credentials_inventory: false)
      end

      it 'returns 404' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'PUT #revoke' do
    context 'when `credentials_inventory` feature is enabled' do
      before do
        stub_licensed_features(credentials_inventory: true, group_saml: true)
      end

      context 'for a group that enforces group managed accounts' do
        context 'for a user with access to view credentials inventory' do
          let_it_be(:current_user) { owner }

          context 'non-existent personal access token specified' do
            it 'returns 404' do
              put :revoke, params: { group_id: group_id.to_param, id: 999999999999999999999999999999999 }

              expect(response).to have_gitlab_http_status(:not_found)
            end
          end

          describe 'with an existing personal access token' do
            context 'personal access token is already revoked' do
              let_it_be(:personal_access_token) { create(:personal_access_token, revoked: true, user: maintainer) }

              it 'returns the flash success message' do
                put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

                expect(response).to redirect_to(group_security_credentials_path)
                expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
              end
            end

            context 'personal access token is already expired' do
              let_it_be(:personal_access_token) { create(:personal_access_token, expires_at: 5.days.ago, user: maintainer) }

              it 'returns the flash success message' do
                put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

                expect(response).to redirect_to(group_security_credentials_path)
                expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
              end
            end

            context 'does not have permissions to revoke the credential' do
              let_it_be(:personal_access_token) { create(:personal_access_token, user: maintainer) }

              before do
                expect(Ability).to receive(:allowed?).with(current_user, :log_in, :global) { true }
                expect(Ability).to receive(:allowed?).with(current_user, :read_cross_project, :global) { true }
                expect(Ability).to receive(:allowed?).with(current_user, :read_group, group_with_managed_accounts) { true }
                expect(Ability).to receive(:allowed?).with(current_user, :read_group_credentials_inventory, group_with_managed_accounts) { true }
                expect(Ability).to receive(:allowed?).with(current_user, :revoke_token, personal_access_token) { false }
              end

              it 'returns the flash error message' do
                put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

                expect(response).to redirect_to(group_security_credentials_path)
                expect(flash[:alert]).to eql 'Not permitted to revoke'
              end
            end

            context 'personal access token is already revoked' do
              let_it_be(:personal_access_token) { create(:personal_access_token, revoked: true, user: maintainer) }

              it 'returns the flash success message' do
                put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

                expect(response).to redirect_to(group_security_credentials_path)
                expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
              end
            end

            context 'personal access token is already expired' do
              let_it_be(:personal_access_token) { create(:personal_access_token, expires_at: 5.days.ago, user: maintainer) }

              it 'returns the flash success message' do
                put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

                expect(response).to redirect_to(group_security_credentials_path)
                expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
              end
            end

            context 'personal access token is not revoked or expired' do
              let_it_be(:personal_access_token) { create(:personal_access_token, user: maintainer) }

              it 'returns the flash success message' do
                put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

                expect(response).to redirect_to(group_security_credentials_path)
                expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
              end
            end
          end
        end

        context 'for a user without access to view credentials inventory' do
          let_it_be(:current_user) { maintainer }
          let_it_be(:personal_access_token) { create(:personal_access_token, user: owner) }

          it 'responds with 404' do
            put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context 'for a group that does not enforce group managed accounts' do
        let_it_be(:current_user) { owner }
        let_it_be(:personal_access_token) { create(:personal_access_token, user: maintainer) }
        let_it_be(:group_id) { create(:group).to_param }

        it 'responds with 404' do
          put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when `credentials_inventory` feature is disabled' do
      let_it_be(:current_user) { owner }
      let_it_be(:personal_access_token) { create(:personal_access_token, user: owner) }

      before do
        stub_licensed_features(credentials_inventory: false)
      end

      it 'returns 404' do
        put :revoke, params: { group_id: group_id.to_param, id: personal_access_token.id }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
