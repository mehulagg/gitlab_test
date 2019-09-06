# frozen_string_literal: true
require 'spec_helper'

describe API::FeatureFlag::Scopes do
  include FeatureFlagHelpers

  let(:project) { create(:project, :repository) }
  let(:developer) { create(:user) }

  before do
    stub_licensed_features(feature_flags: true)

    project.add_developer(developer)
  end

  describe 'GET /projects/:id/feature_flags/:name/scopes' do
    context 'when there are two scopes' do
      let!(:feature_flag) { create_flag(project, 'test') }
      let!(:additional_scope) { create_scope(feature_flag, 'production', false) }

      it 'returns scopes' do
        get api("/projects/#{project.id}/feature_flags/#{feature_flag.name}/scopes", developer)

        puts "#{self.class.name} - #{__callee__}: json_response: #{JSON.pretty_generate(json_response)}"
        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.count).to eq(2)
        expect(json_response.first['environment_scope']).to eq(feature_flag.scopes[0].environment_scope)
        expect(json_response.second['environment_scope']).to eq(feature_flag.scopes[1].environment_scope)
      end
    end
  end

  describe 'GET /projects/:id/feature_flags/:name/scopes/:scope_id' do
    context 'when there is a feature flag' do
      let!(:feature_flag) { create(:operations_feature_flag, project: project) }
      let(:default_scope) { feature_flag.default_scope }

      it 'returns a scope' do
        get api("/projects/#{project.id}/feature_flags/#{feature_flag.name}/scopes/#{default_scope.id}", developer)

        puts "#{self.class.name} - #{__callee__}: json_response: #{JSON.pretty_generate(json_response)}"
        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['id']).to eq(default_scope.id)
        expect(json_response['active']).to eq(default_scope.active)
        expect(json_response['environment_scope']).to eq(default_scope.environment_scope)
      end
    end
  end

  describe 'POST /projects/:id/feature_flags/:name/scopes' do
    let(:params) do
      {
        environment_scope: 'staging',
        active: false,
        strategies: [{
          name: 'userWithId',
          parameters: { userIds: 'user:1,project:1,group:1' }
        }].to_json
      }
    end

    let!(:feature_flag) { create(:operations_feature_flag, project: project) }

    it 'creates a new scope' do
      post api("/projects/#{project.id}/feature_flags/#{feature_flag.name}/scopes", developer), params: params

      expect(response).to have_gitlab_http_status(:created)

      scope = feature_flag.scopes.find_by_environment_scope(params[:environment_scope])
      expect(scope.active).to eq(params[:active])
      expect(scope.strategies).to eq(JSON.parse(params[:strategies]))
    end
  end

  describe 'PUT /projects/:id/feature_flags/:name/scopes/:scope_id' do
    let(:params) { { active: true } }

    let!(:feature_flag) { create(:operations_feature_flag, project: project) }
    let!(:production_scope) { create_scope(feature_flag, 'production', false) }

    it 'updates the name' do
      put api("/projects/#{project.id}/feature_flags/#{feature_flag.name}/scopes/#{production_scope.id}", developer), params: params

      expect(response).to have_gitlab_http_status(:ok)

      production_scope.reload
      expect(production_scope.active).to eq(true)
    end
  end

  describe 'DELETE /projects/:id/feature_flags/:name/scopes/:scope_id' do
    let!(:feature_flag) { create(:operations_feature_flag, project: project) }
    let!(:production_scope) { create_scope(feature_flag, 'production', false) }

    it 'destroys the scope' do
      expect do
        delete api("/projects/#{project.id}/feature_flags/#{feature_flag.name}/scopes/#{production_scope.id}", developer)
      end.to change { Operations::FeatureFlagScope.count }.by(-1)

      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end
