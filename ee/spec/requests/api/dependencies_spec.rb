# frozen_string_literal: true

require 'spec_helper'

describe API::Dependencies do
  set(:project) { create(:project, :public) }
  set(:user) { create(:user) }

  describe "GET /projects/:id/dependencies" do
    context 'with an authorized user with proper permissions' do
      before do
        project.add_developer(user)
      end

      it 'returns all dependencies' do
        get api("/projects/#{project.id}/dependencies", user)

        expect(response).to have_gitlab_http_status(200)
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
