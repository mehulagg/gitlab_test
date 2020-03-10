# frozen_string_literal: true

require 'spec_helper'

describe API::ProjectTerraformStates do
  let(:project) { create(:project) }
  let!(:state) { create(:terraform_state, project_id: project.id) }
  let(:developer) { create(:user) }

  before do
    project.add_developer(developer)
  end

  describe 'GET /projects/:id/terraform_states/:name' do
    it 'returns terraform state belonging to a project of given state name' do
      get api("/projects/#{project.id}/terraform_states/#{state.name}", developer)

      expect(response).to have_gitlab_http_status(:ok)
      expect(response.body).to eq('some terraform state value')
    end

    it 'returns 404 for not existing state' do
      get api("/projects/#{project.id}/terraform_states/foo", developer)
      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  describe 'POST /projects/:id/terraform_states/:name' do
    context 'when terraform state with a given name is already present' do
      it 'updates the state' do
        post api("/projects/#{project.id}/terraform_states/#{state.name}", developer),
        params: '{ "instance": "example-instance" }',
        headers: { 'Content-Type' => 'text/plain' }

        expect(response).to have_gitlab_http_status(:success)
        expect(project.terraform_states.first.value).to eq('{ "instance": "example-instance" }')
        expect(project.terraform_states.length).to eq(1)
      end
    end
    context 'when there is no terraform state of a given name' do
      it 'creates a new state' do
        post api("/projects/#{project.id}/terraform_states/example2", developer),
        params: '{ "database": "example-database" }'

        expect(response).to have_gitlab_http_status(:success)
        expect(project.terraform_states.second.value).to eq('{ "database": "example-database" }')
        expect(project.terraform_states.length).to eq(2)
      end
    end
  end

  describe 'DELETE /projects/:id/terraform_states/:name' do
    it 'deletes the state' do
      delete api("/projects/#{project.id}/terraform_states/#{state.name}", developer)
      expect(response).to have_gitlab_http_status(:success)
      expect(project.terraform_states.length).to eq(0)
    end

    it 'returns 404 for not existing state' do
      delete api("/projects/#{project.id}/terraform_states/foo", developer)
      expect(response).to have_gitlab_http_status(:not_found)
      expect(project.terraform_states.length).to eq(1)
    end
  end
end
