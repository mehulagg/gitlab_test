# frozen_string_literal: true

require 'spec_helper'

describe API::Dependencies do
  set(:project) { create(:project, :public) }
  set(:user) { create(:user) }

  describe "GET /projects/:id/dependencies" do
    before do
      stub_licensed_features(dependency_list: true)
    end

    context 'with an authorized user with proper permissions' do
      let!(:pipeline) { create(:ee_ci_pipeline, :with_dependency_list_report, project: project) }

      before do
        project.add_developer(user)

        get api("/projects/#{project.id}/dependencies", user)
      end

      it 'returns all dependencies' do

        expect(response).to have_gitlab_http_status(200)
        expect(json_response).to be_a(Hash)
      end
    end

    # context 'with authorized user without read permissions' do
    # end
    #
    # context 'with no project access' do
    # end
    #
    # context 'with unknown project' do
    # end
  end
end
