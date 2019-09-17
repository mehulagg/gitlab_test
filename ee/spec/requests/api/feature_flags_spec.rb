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

        expect(response).to have_gitlab_http_status(:ok)
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

  describe 'POST /projects/:id/feature_flags/enable' do
    let(:params) do
      {
        name: 'awesome-feature',
        environment_scope: 'production',
        strategy: { name: 'userWithId', parameters: { userIds: 'Project:1' } }.to_json
      }
    end

    context 'when feature flag & scope do not exist yet' do
      it 'creates a new feature flag and scope' do
        post api("/projects/#{project.id}/feature_flags/enable", developer), params: params

        expect(response).to have_gitlab_http_status(:created)

        feature_flag = project.operations_feature_flags.last
        expect(feature_flag.name).to eq(params[:name])

        scope = feature_flag.scopes.find_by_environment_scope(params[:environment_scope])
        expect(scope.strategies).to eq([JSON.parse(params[:strategy])])
      end
    end

    context 'when feature flag exists already' do
      let!(:feature_flag) { create_flag(project, params[:name]) }

      context 'when environment scope does not exist yet' do
        it 'creates a new scope' do
          post api("/projects/#{project.id}/feature_flags/enable", developer), params: params

          expect(response).to have_gitlab_http_status(:created)

          scope = feature_flag.scopes.find_by_environment_scope(params[:environment_scope])
          expect(scope.strategies).to eq([JSON.parse(params[:strategy])])
        end
      end

      context 'when scope exists already' do
        let(:defined_strategy) { { name: 'userWithId', parameters: { userIds: 'Project:2' }} }

        before do
          create_scope(feature_flag, params[:environment_scope], true, [defined_strategy])
        end

        it 'adds an additional strategy param' do
          post api("/projects/#{project.id}/feature_flags/enable", developer), params: params

          expect(response).to have_gitlab_http_status(:created)

          scope = feature_flag.scopes.find_by_environment_scope(params[:environment_scope])
          expect(scope.strategies).to eq([defined_strategy.deep_stringify_keys, JSON.parse(params[:strategy])])
        end
      end
    end
  end

  describe 'POST /projects/:id/feature_flags/disable' do
    let(:params) do
      {
        name: 'awesome-feature',
        environment_scope: 'production',
        strategy: { name: 'userWithId', parameters: { userIds: 'Project:1' } }.to_json
      }
    end

    context 'when feature flag & scope do not exist yet' do
      it 'returns not modified' do
        post api("/projects/#{project.id}/feature_flags/disable", developer), params: params

        expect(response).to have_gitlab_http_status(:not_modified)
      end
    end

    context 'when feature flag exists already' do
      let!(:feature_flag) { create_flag(project, params[:name]) }

      context 'when environment scope does not exist yet' do
        it 'returns not modified' do
          post api("/projects/#{project.id}/feature_flags/disable", developer), params: params

          expect(response).to have_gitlab_http_status(:not_modified)
        end
      end

      context 'when scope exists already and can find the corresponding one' do
        let(:defined_strategies) { [{ name: 'userWithId', parameters: { userIds: 'Project:1' }}, { name: 'userWithId', parameters: { userIds: 'Project:2' }}] }

        before do
          create_scope(feature_flag, params[:environment_scope], true, defined_strategies)
        end

        it 'removes the strategy from the scope' do
          post api("/projects/#{project.id}/feature_flags/disable", developer), params: params

          expect(response).to have_gitlab_http_status(:created)

          scope = feature_flag.scopes.find_by_environment_scope(params[:environment_scope])
          expect(scope.strategies).to eq([{ name: 'userWithId', parameters: { userIds: 'Project:2' }}.deep_stringify_keys])
        end

        context 'when strategies become empty array afterward' do
          let(:defined_strategies) { [{ name: 'userWithId', parameters: { userIds: 'Project:1' }}] }

          it 'deactivates the scope' do
            post api("/projects/#{project.id}/feature_flags/disable", developer), params: params
  
            expect(response).to have_gitlab_http_status(:created)
  
            scope = feature_flag.scopes.find_by_environment_scope(params[:environment_scope])
            expect(scope.active).to eq(false)
          end
        end
      end

      context 'when scope exists already but cannot find the corresponding one' do
        let(:defined_strategy) { { name: 'userWithId', parameters: { userIds: 'Project:2' }} }

        before do
          create_scope(feature_flag, params[:environment_scope], true, [defined_strategy])
        end

        it 'returns not modified' do
          post api("/projects/#{project.id}/feature_flags/disable", developer), params: params

          expect(response).to have_gitlab_http_status(:not_modified)
        end
      end
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
