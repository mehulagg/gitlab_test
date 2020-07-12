# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Integrations::Jira::IssuesController do
  include ProjectForksHelper

  let(:project) { create(:project) }
  let(:user)    { create(:user) }

  describe 'GET #index' do
    before do
      sign_in(user)
      project.add_developer(user)
      create(:jira_service, project: project)
    end

    context 'when jira_integration feature disabled' do
      it 'returns 404 status' do
        stub_feature_flags(jira_integration: false)

        get :index, params: { namespace_id: project.namespace, project_id: project }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    it 'renders the "index" template' do
      get :index, params: { namespace_id: project.namespace, project_id: project }

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:index)
    end

    context 'when project has moved' do
      let(:new_project) { create(:project) }

      before do
        project.route.destroy!
        new_project.redirect_routes.create!(path: project.full_path)
        new_project.add_developer(user)
      end

      it 'redirects to the new issue tracker from the old one' do
        get :index, params: { namespace_id: project.namespace, project_id: project }

        expect(response).to redirect_to(project_integrations_jira_issues_path(new_project))
        expect(response).to have_gitlab_http_status(:found)
      end
    end

    context 'json request' do
      let(:jira_issues) { [] }

      it 'returns a list of serialized jira issues' do
        expect_next_instance_of(Projects::Integrations::Jira::IssuesFinder) do |finder|
          expect(finder).to receive(:execute).and_return(jira_issues)
        end

        expect_next_instance_of(Integrations::Jira::IssueSerializer) do |serializer|
          expect(serializer).to receive(:represent).with(jira_issues, project: project)
        end

        get :index, params: { namespace_id: project.namespace, project_id: project }, format: :json
      end

      it 'renders bad request for IntegrationError' do
        expect_any_instance_of(Projects::Integrations::Jira::IssuesFinder).to receive(:execute)
          .and_raise(Projects::Integrations::Jira::IntegrationError, 'Integration error')

        get :index, params: { namespace_id: project.namespace, project_id: project }, format: :json

        expect(response).to have_gitlab_http_status(:bad_request)
        expect(json_response['errors']).to eq ['Integration error']
      end

      it 'renders bad request for RequestError' do
        expect_any_instance_of(Projects::Integrations::Jira::IssuesFinder).to receive(:execute)
          .and_raise(Projects::Integrations::Jira::RequestError, 'Request error')

        get :index, params: { namespace_id: project.namespace, project_id: project }, format: :json

        expect(response).to have_gitlab_http_status(:bad_request)
        expect(json_response['errors']).to eq ['Request error']
      end

      it 'sets pagination headers' do
        expect_next_instance_of(Projects::Integrations::Jira::IssuesFinder) do |finder|
          expect(finder).to receive(:execute).and_return(jira_issues)
        end

        get :index, params: { namespace_id: project.namespace, project_id: project }, format: :json

        expect(response).to include_pagination_headers
        expect(response.headers['X-Page']).to eq '1'
        expect(response.headers['X-Per-Page']).to eq Jira::Requests::Issues::ListService::PER_PAGE.to_s
        expect(response.headers['X-Total']).to eq '0'
      end

      context 'when parameters are passed' do
        shared_examples 'proper parameter values' do
          it 'properly set the values' do
            expect_next_instance_of(Projects::Integrations::Jira::IssuesFinder, project, expected_params) do |finder|
              expect(finder).to receive(:execute).and_return(jira_issues)
            end

            get :index, params: { namespace_id: project.namespace, project_id: project }.merge(params), format: :json
          end
        end

        context 'when there are no params' do
          it_behaves_like 'proper parameter values' do
            let(:params) { {} }
            let(:expected_params) { { 'state' => 'opened', 'sort' => 'created_date' } }
          end
        end

        context 'when pagination params' do
          it_behaves_like 'proper parameter values' do
            let(:params) { { 'page' => '12', 'per_page' => '20' } }
            let(:expected_params) { { 'page' => '12', 'per_page' => '20', 'state' => 'opened', 'sort' => 'created_date' } }
          end
        end

        context 'when state is closed' do
          it_behaves_like 'proper parameter values' do
            let(:params) { { 'state' => 'closed' } }
            let(:expected_params) { { 'state' => 'closed', 'sort' => 'updated_desc' } }
          end
        end

        context 'when invalid params' do
          it_behaves_like 'proper parameter values' do
            let(:params) { { 'invalid' => '12' } }
            let(:expected_params) { { 'state' => 'opened', 'sort' => 'created_date' } }
          end
        end
      end
    end
  end

  context 'external authorization' do
    before do
      sign_in user
      project.add_developer(user)
    end

    it_behaves_like 'unauthorized when external service denies access' do
      subject { get :index, params: { namespace_id: project.namespace, project_id: project } }
    end
  end
end
