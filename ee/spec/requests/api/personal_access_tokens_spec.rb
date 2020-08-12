# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::PersonalAccessTokens do
  let_it_be(:path) { '/personal_access_tokens' }
  let_it_be(:token1) { create(:personal_access_token) }
  let_it_be(:token2) { create(:personal_access_token) }
  let_it_be(:current_user) { create(:user) }

  context 'when unlicensed' do
    before do
      stub_licensed_features(personal_access_token_api_management: false)
    end

    it 'responds with unauthorized' do
      get api(path, current_user)

      expect(response).to have_gitlab_http_status(:unauthorized)
    end
  end

  context 'when licensed' do
    before do
      stub_licensed_features(personal_access_token_api_management: true)
    end

    context 'logged in as an Administrator' do
      let_it_be(:current_user) { create(:admin) }

      it 'returns all PATs by default' do
        get api(path, current_user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.count).to eq(PersonalAccessToken.all.count)
      end

      context 'filtered with user_id parameter' do
        it 'returns only PATs belonging to that user' do
          get api(path, current_user), params: { user_id: token1.user.id }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.count).to eq(1)
          expect(json_response.first['user_id']).to eq(token1.user.id)
        end
      end
    end

    context 'logged in as a non-Administrator' do
      let_it_be(:current_user) { create(:user) }
      let_it_be(:user) { create(:user) }
      let_it_be(:token) { create(:personal_access_token, user: current_user)}
      let_it_be(:other_token) { create(:personal_access_token, user: user) }

      it 'returns all PATs belonging to the signed-in user' do
        get api(path, current_user, personal_access_token: token)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.count).to eq(1)
        expect(json_response.map { |r| r['user_id'] }.uniq).to contain_exactly(current_user.id)
      end

      context 'filtered with user_id parameter' do
        it 'returns PATs belonging to the specific user' do
          get api(path, current_user, personal_access_token: token), params: { user_id: current_user.id }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.count).to eq(1)
          expect(json_response.map { |r| r['user_id'] }.uniq).to contain_exactly(current_user.id)
        end

        it 'is unauthorized if filtered by a user other than current_user' do
          get api(path, current_user, personal_access_token: token), params: { user_id: user.id }

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    context 'not authenticated' do
      it 'is forbidden' do
        get api(path)

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end
  end
end
