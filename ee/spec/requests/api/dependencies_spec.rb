# frozen_string_literal: true

require 'spec_helper'

describe API::Dependencies do
  set(:project) { create(:project, :public, :repository_private) }
  set(:user) { create(:user) }

  describe "GET /projects/:id/dependencies" do
    before do
      stub_licensed_features(dependency_list: true, security_dashboard: true)
    end

    context 'with an authorized user with proper permissions' do
      let!(:pipeline) { create(:ee_ci_pipeline, :with_dependency_list_report, project: project) }

      before do
        project.add_developer(user)
      end

      it 'returns all dependencies' do
        get api("/projects/#{project.id}/dependencies", user)

        expect(response).to have_gitlab_http_status(200)
        expect(response).to match_response_schema('public_api/v4/dependencies', dir: 'ee')

        expect(json_response.length).to eq(21)
      end

      context 'with filter options' do
        it 'returns yarn dependencies' do
          get api("/projects/#{project.id}/dependencies", user), params: { package_manager: 'yarn' }

          expect(json_response.length).to eq(19)
        end
      end
    end

    context 'with authorized user without read permissions' do
      it 'responds with 403 Forbidden' do
        get api("/projects/#{project.id}/dependencies", user)

        expect(response).to have_gitlab_http_status(403)
      end
    end

    context 'with no project access' do
      it 'responds with 404 Not Found' do
        private_project = create(:project, :private)

        get api("/projects/#{private_project.id}/dependencies", user)

        expect(response).to have_gitlab_http_status(404)
      end
    end
  end
end
