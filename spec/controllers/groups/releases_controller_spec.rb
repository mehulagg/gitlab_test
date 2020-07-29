# frozen_string_literal: true

require 'spec_helper'

describe Groups::ReleasesController do
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

      before do
        get :index, params: { group_id: group, format: format }
      end

      it 'returns an application/json content_type' do
        expect(response.content_type).to eq 'application/json'
      end

      context 'the user is not authorized' do
        it "returns all group's public project's releases as JSON, ordered by released_at" do
          expect(response.body).to eq([release_2, release_1].to_json)
        end
      end

      context 'the user is authorized' do
        it "returns all group's public and private project's releases as JSON, ordered by released_at" do
          sign_in(developer)

          get :index, params: { group_id: group, format: format }

          expect(response.body).to eq([private_release_2, private_release_1, release_2, release_1].to_json)
        end
      end
    end
  end
end
