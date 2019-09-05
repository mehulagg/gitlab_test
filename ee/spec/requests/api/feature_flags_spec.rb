# frozen_string_literal: true
require 'spec_helper'

describe API::FeatureFlags do
  include FeatureFlagHelpers

  let(:project) { create(:project, :repository) }
  let(:developer) { create(:user) }
  let(:non_project_member) { create(:user) }

  before do
    stub_licensed_features(feature_flags: true)

    project.add_developer(developer)
  end

  describe 'GET /projects/:id/feature_flags' do
    context 'when there are two feature flags' do
      let!(:feature_flag_1) do
        create(:operations_feature_flag, project: project)
      end

      let!(:feature_flag_2) do
        create(:operations_feature_flag, project: project)
      end

      it 'returns feature flags' do
        get api("/projects/#{project.id}/feature_flags", developer)

        puts "#{self.class.name} - #{__callee__}: json_response: #{JSON.pretty_generate(json_response)}"
        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.count).to eq(2)
        expect(json_response.first['name']).to eq(feature_flag_1.name)
        expect(json_response.second['name']).to eq(feature_flag_2.name)
      end
    end
  end

  describe 'GET /projects/:id/feature_flags/:name' do
    context 'when there is a feature flag' do
      let!(:feature_flag) do
        create(:operations_feature_flag, project: project)
      end

      it 'returns a feature flag entry' do
        get api("/projects/#{project.id}/feature_flags/#{feature_flag.name}", developer)

        puts "#{self.class.name} - #{__callee__}: json_response: #{JSON.pretty_generate(json_response)}"
        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['id']).to eq(feature_flag.id)
        expect(json_response['name']).to eq(feature_flag.name)
        expect(json_response['description']).to eq(feature_flag.description)
      end
    end
  end

  describe 'POST /projects/:id/feature_flags' do
    let(:params) do
      {
        name: 'awesome-feature',
        description: 'aaaaaaaa',
        scopes_attributes: [
          {
            environment_scope: '*',
            active: true,
            strategies: [{
              name: 'default',
              parameters: {}
            }].to_json
          },
          {
            environment_scope: 'production',
            active: true,
            strategies: [{
              name: 'userWithId',
              parameters: {
                userIds: 'user:1'
              }
            }].to_json
          }]
      }
    end

    it 'creates a new feature flag' do
      post api("/projects/#{project.id}/feature_flags", developer), params: params

      expect(response).to have_gitlab_http_status(:created)

      feature_flag = project.operations_feature_flags.last
      expect(feature_flag.name).to eq(params[:name])
      expect(feature_flag.description).to eq(params[:description])

      feature_flag.scopes.each_with_index do |scope, index|
        expect(scope.environment_scope).to eq(params[:scopes_attributes][index][:environment_scope])
        expect(scope.active).to eq(params[:scopes_attributes][index][:active])
        expect(scope.strategies).to eq(JSON.parse(params[:scopes_attributes][index][:strategies]))
      end
    end
  end

  describe 'PUT /projects/:id/feature_flags/:name' do
    let(:params) { { description: 'bbbb' } }

    let!(:feature_flag) do
      create(:operations_feature_flag, project: project, description: 'aaaaa')
    end

    it 'updates the name' do
      put api("/projects/#{project.id}/feature_flags/#{feature_flag.name}", developer), params: params

      expect(response).to have_gitlab_http_status(:ok)
      expect(project.operations_feature_flags.last.description).to eq('bbbb')
    end
  end

  describe 'DELETE /projects/:id/feature_flags/:name' do
    let!(:feature_flag) do
      create(:operations_feature_flag, project: project)
    end

    it 'destroys the release' do
      expect do
        delete api("/projects/#{project.id}/feature_flags/#{feature_flag.name}", developer)
      end.to change { Operations::FeatureFlag.count }.by(-1)

      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end
