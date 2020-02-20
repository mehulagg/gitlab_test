# frozen_string_literal: true

require 'spec_helper'

describe API::DeployTokens do
  let_it_be(:user)          { create(:user) }
  let_it_be(:creator)       { create(:user) }
  let_it_be(:project)       { create(:project, creator_id: creator.id) }
  let_it_be(:group)         { create(:group) }
  let!(:project_deploy_token) { create(:deploy_token, projects: [project]) }
  let!(:group_deploy_token)   { create(:deploy_token, :group, groups: [group]) }

  describe 'GET /deploy_tokens' do
    subject do
      get api('/deploy_tokens', user)
      response
    end

    context 'when unauthenticated' do
      let(:user) { nil }

      it { is_expected.to have_gitlab_http_status(:unauthorized) }
    end

    context 'when authenticated as non-admin user' do
      let(:user) { creator }

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end

    context 'when authenticated as admin' do
      let(:user) { create(:admin) }

      it { is_expected.to have_gitlab_http_status(:ok) }

      it 'returns all deploy tokens' do
        subject

        expect(response).to include_pagination_headers
        expect(response).to match_response_schema('public_api/v4/deploy_tokens')
      end
    end
  end

  describe 'GET /projects/:id/deploy_tokens' do
    subject do
      get api("/projects/#{project.id}/deploy_tokens", user)
      response
    end

    context 'when unauthenticated' do
      let(:user) { nil }

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end

    context 'when authenticated as non-admin user' do
      before do
        project.add_developer(user)
      end

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end

    context 'when authenticated as maintainer' do
      let!(:other_deploy_token) { create(:deploy_token) }

      before do
        project.add_maintainer(user)
      end

      it { is_expected.to have_gitlab_http_status(:ok) }

      it 'returns all deploy tokens for the project' do
        subject

        expect(response).to include_pagination_headers
        expect(response).to match_response_schema('public_api/v4/deploy_tokens')
      end

      it 'does not return deploy tokens for other projects' do
        subject

        token_ids = json_response.map { |token| token['id'] }
        expect(token_ids).not_to include(other_deploy_token.id)
      end
    end
  end

  describe 'POST /groups/:id/deploy_tokens' do
    let(:params) do
      {
        name: 'Foo',
        expires_at: 1.year.from_now,
        read_repository: true,
        read_registry: false,
        username: 'Bar'
      }
    end

    subject do
      post api("/groups/#{group.id}/deploy_tokens", user), params: params
      response
    end

    context 'when unauthenticated' do
      let(:user) { nil }

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end

    context 'when authenticated as non-admin user' do
      before do
        group.add_developer(user)
      end

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end

    context 'when authenticated as maintainer' do
      before do
        group.add_maintainer(user)
      end

      it 'creates the deploy token' do
        expect { subject }.to change { DeployToken.count }.by(1)

        expect(response).to have_gitlab_http_status(:created)
        expect(response).to match_response_schema('public_api/v4/deploy_token')
      end
    end
  end
end
