# frozen_string_literal: true

require 'spec_helper'

describe QaSessionsController do
  include DeviseHelpers

  before do
    set_devise_mapping(context: @request)
  end

  describe 'GET #create' do
    let(:username) { 'qa_user' }
    let(:password) { 'qa_password' }
    let(:qa_token) { 'super-secret-token' }

    let!(:user) { create(:user, username: 'qa_user', password: 'qa_password', password_confirmation: 'qa_password') }

    let(:params) { { user: { login: login, password: password }, gitlab_qa_formless_login_token: qa_token } }

    subject { post(:create, params: params) }

    before do
      stub_env('GITLAB_QA_FORMLESS_LOGIN_TOKEN', 'super-secret-token')
    end

    context 'with incorrect or blank parameters' do
      using RSpec::Parameterized::TableSyntax

      where(:login, :password, :qa_token, :response_status) do
        username         | password         | 'wrong_qa_token' | :forbidden
        username         | password         | nil              | :forbidden
        username         | nil              | 'wrong_qa_token' | :forbidden
        username         | nil              | qa_token         | :unauthorized
        username         | nil              | nil              | :forbidden
        username         | 'wrong_password' | 'wrong_qa_token' | :forbidden
        username         | 'wrong_password' | qa_token         | :unauthorized
        username         | 'wrong_password' | nil              | :forbidden
        nil              | password         | 'wrong_qa_token' | :forbidden
        nil              | password         | qa_token         | :unauthorized
        nil              | password         | nil              | :forbidden
        nil              | nil              | 'wrong_qa_token' | :forbidden
        nil              | nil              | qa_token         | :unauthorized
        nil              | nil              | nil              | :forbidden
        nil              | 'wrong_password' | 'wrong_qa_token' | :forbidden
        nil              | 'wrong_password' | qa_token         | :unauthorized
        nil              | 'wrong_password' | nil              | :forbidden
        'wrong_username' | password         | 'wrong_qa_token' | :forbidden
        'wrong_username' | password         | qa_token         | :unauthorized
        'wrong_username' | password         | nil              | :forbidden
        'wrong_username' | nil              | 'wrong_qa_token' | :forbidden
        'wrong_username' | nil              | qa_token         | :unauthorized
        'wrong_username' | nil              | nil              | :forbidden
        'wrong_username' | 'wrong_password' | 'wrong_qa_token' | :forbidden
        'wrong_username' | 'wrong_password' | qa_token         | :unauthorized
        'wrong_username' | 'wrong_password' | nil              | :forbidden
      end

      with_them do
        it 'prevents user login' do
          subject

          expect(response).to have_gitlab_http_status(response_status)
          expect(request.env['warden']).not_to be_authenticated
        end
      end
    end

    context 'with the right parameters' do
      let(:login) { username }

      it 'allows the user to log in' do
        subject

        expect(request.env['warden']).to be_authenticated
        expect(response).to have_gitlab_http_status(:found)
      end
    end
  end
end
