# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::ReleasesController do
  let(:group) { create(:group) }
  let!(:project)         { create(:project, :repository, :public, namespace: group) }
  let!(:private_project) { create(:project, :repository, :private, namespace: group) }
  let(:developer)        { create(:user) }
  let!(:release_1)       { create(:release, project: project, released_at: Time.zone.parse('2020-02-15')) }
  let!(:release_2)       { create(:release, project: project, released_at: Time.zone.parse('2020-02-20')) }
  let!(:private_release_1)       { create(:release, project: private_project, released_at: Time.zone.parse('2020-03-01')) }
  let!(:private_release_2)       { create(:release, project: private_project, released_at: Time.zone.parse('2020-03-05')) }

  before do
    private_project.add_developer(developer)
  end

  describe 'GET #index' do
    context 'as json' do
      let(:format) { :json }

      subject { get :index, params: { group_id: group }, format: format }

      context 'json_response' do
        before do
          subject
        end

        it 'returns an application/json content_type' do
          expect(response.content_type).to eq 'application/json'
        end

        it 'returns OK' do
          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'the user is not authorized' do
        before do
          subject
        end

        it "returns all group's public project's releases as JSON, ordered by released_at" do
          expect(response.body).to eq([release_2, release_1].to_json)
        end

        it 'returns OK' do
          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'the user is authorized' do
        it "returns all group's public and private project's releases as JSON, ordered by released_at" do
          sign_in(developer)

          subject

          expect(response.body).to eq([private_release_2, private_release_1, release_2, release_1].to_json)
        end
      end

      context 'N+1 queries' do
        it 'avoids N+1 database queries' do
          control_count = ActiveRecord::QueryRecorder.new { subject }.count

          create_list(:release, 5, project: project)

          expect { subject }.not_to exceed_query_limit(control_count)
        end
      end
    end
  end
end
