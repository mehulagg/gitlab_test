# frozen_string_literal: true

require 'spec_helper'
#require './app/controllers/projects/releases/evidences_controller.rb'

describe Projects::EvidencesController do
  let!(:project)         { create(:project, :repository, :public) }
  let!(:private_project) { create(:project, :repository, :private) }
  let(:user)             { developer }
  let(:developer)        { create(:user) }
  let(:reporter)         { create(:user) }
  let!(:release_1)       { create(:release, project: project, released_at: Time.zone.parse('2018-10-18')) }
  let!(:release_2)       { create(:release, project: project, released_at: Time.zone.parse('2019-10-19')) }

  before do
    project.add_developer(developer)
    project.add_reporter(reporter)
  end

  shared_examples_for 'successful request' do
    it 'renders a 200' do
      subject

      expect(response).to have_gitlab_http_status(:success)
    end
  end

  shared_examples_for 'not found' do
    it 'renders 404' do
      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  shared_examples 'common access controls' do
    it 'renders a 200' do
      get_index

      expect(response.status).to eq(200)
    end

    context 'when the project is private' do
      let(:project) { private_project }

      before do
        sign_in(user)
      end

      context 'when user is a developer' do
        let(:user) { developer }

        it 'renders a 200 for a logged in developer' do
          sign_in(user)

          get_index

          expect(response.status).to eq(200)
        end
      end

      context 'when user is an external user' do
        let(:user) { create(:user) }

        it 'renders a 404 when logged in but not in the project' do
          sign_in(user)

          get_index

          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe 'GET #show' do
    let_it_be(:tag_name) { "v1.1.0-evidence" }
    let!(:release) { create(:release, :with_evidence, project: project, tag: tag_name) }
    let(:evidence) { release.evidences.first }
    let(:tag) { CGI.escape(release.tag) }
    let(:format) { :json }

    subject do
      get :show, params: {
        namespace_id: project.namespace,
        project_id: project.id,
        release_tag: tag,
        id: evidence.id,
        format: format
      }
    end

    before do
      sign_in(user)
    end

    context 'when the user is a developer' do
      it 'returns the correct evidence summary as a json' do
        subject

        expect(json_response).to eq(evidences.summary)
      end

      context 'when the release was created before evidence existed' do
        before do
          evidence.destroy
        end

        it 'returns an empty array' do
          subject

          expect(json_response).to eq([])
        end
      end
    end

    context 'when the user is a guest for the project' do
      before do
        project.add_guest(user)
      end

      context 'when the project is private' do
        let(:project) { private_project }

        it_behaves_like 'not found'
      end

      context 'when the project is public' do
        it_behaves_like 'successful request'
      end
    end

    context 'when release is associated to a milestone which includes an issue' do
      let_it_be(:project) { create(:project, :repository, :public) }
      let_it_be(:issue) { create(:issue, project: project) }
      let_it_be(:milestone) { create(:milestone, project: project, issues: [issue]) }
      let_it_be(:release) { create(:release, project: project, tag: tag_name, milestones: [milestone]) }

      before do
        create(:evidence, release: release)
      end

      shared_examples_for 'does not show the issue in evidence' do
        it do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.first['release']['milestones']
            .all? { |milestone| milestone['issues'].nil? }).to eq(true)
        end
      end

      shared_examples_for 'evidence not found' do
        it do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      shared_examples_for 'safely expose evidence' do
        it_behaves_like 'does not show the issue in evidence'

        context 'when the issue is confidential' do
          let(:issue) { create(:issue, :confidential, project: project) }

          it_behaves_like 'does not show the issue in evidence'
        end

        context 'when the user is the author of the confidential issue' do
          let(:issue) { create(:issue, :confidential, project: project, author: user) }

          it_behaves_like 'does not show the issue in evidence'
        end

        context 'when project is private' do
          let!(:project) { create(:project, :repository, :private) }

          it_behaves_like 'evidence not found'
        end

        context 'when project restricts the visibility of issues to project members only' do
          let!(:project) { create(:project, :repository, :issues_private) }

          it_behaves_like 'evidence not found'
        end
      end

      context 'when user is non-project member' do
        let(:user) { create(:user) }

        it_behaves_like 'safely expose evidence'
      end

      context 'when user is auditor', if: Gitlab.ee? do
        let(:user) { create(:user, :auditor) }

        it_behaves_like 'safely expose evidence'
      end

      context 'when external authorization control is enabled' do
        let(:user) { create(:user) }

        before do
          stub_application_setting(external_authorization_service_enabled: true)
        end

        it_behaves_like 'evidence not found'
      end
    end
  end

  private

  def get_index
    get :index, params: { namespace_id: project.namespace, project_id: project, format: format }
  end
end
