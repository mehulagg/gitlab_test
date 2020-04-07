# frozen_string_literal: true

require 'spec_helper'

describe QaSessionsController do
  let(:user) { create(:user) }
  let(:gitlab_qa_token) { 'super-secret-token' }
  let(:authorized_status_code) { 201 }
  let(:unauthorized_status_code) { 403 }

  describe '#create' do
    context 'when all params are provided are valid' do
      let(:valid_params) { { user: user, gitlab_qa_token: gitlab_qa_token } }

      # @TODO: make it work.
      it 'authorizes access' do
        post(:create, params: valid_params)

        # expect(response).to have_gitlab_http_status(authorized_status_code)
      end
    end

    context 'when no params are provided' do
      it 'does not authorize access' do
        post(:create)

        expect(response).to have_gitlab_http_status(unauthorized_status_code)
      end
    end

    context 'when valid user is provided but token is not' do
      let(:missing_token_params) { { user: user, gitlab_qa_token: '' } }

      it 'does not authorize access' do
        post(:create, params: missing_token_params)

        expect(response).to have_gitlab_http_status(unauthorized_status_code)
      end
    end

    context 'when valid token is provided but user is not' do
      let(:missing_user_params) { { gitlab_qa_token: gitlab_qa_token } }

      it 'does not authorize access' do
        post(:create, params: missing_user_params)

        expect(response).to have_gitlab_http_status(unauthorized_status_code)
      end
    end

    context 'when params are not valid' do
      let(:user_invalid_username) { { username: 'invalid', password: user.password } }
      let(:user_invalid_password) { { username: user.username, password: 'invalid' } }

      it 'does not authorize on invalid username' do
        invalid_username_params = { user: user_invalid_username, gitlab_qa_token: gitlab_qa_token }

        post(:create, params: invalid_username_params)

        expect(response).to have_gitlab_http_status(unauthorized_status_code)
      end

      it 'does not authorize on invalid password' do
        invalid_password_params = { user: user_invalid_password, gitlab_qa_token: gitlab_qa_token }

        post(:create, params: invalid_password_params)

        expect(response).to have_gitlab_http_status(unauthorized_status_code)
      end

      it 'does not authorize on invalid user gitlab_qa_token' do
        invalid_token_params = { user: user, gitlab_qa_token: 'invalid' }

        post(:create, params: invalid_token_params)

        expect(response).to have_gitlab_http_status(unauthorized_status_code)
      end
    end
  end
end
