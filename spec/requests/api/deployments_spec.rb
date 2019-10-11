require 'spec_helper'

describe API::Deployments do
  using RSpec::Parameterized::TableSyntax

  let(:maintainer) { create(:user) }
  let(:developer)  { create(:user) }
  let(:non_member) { create(:user) }
  let(:users) do
    {
      maintainer: maintainer,
      developer: developer,
      non_member: non_member
    }
  end

  before do
    project.add_maintainer(maintainer)
    project.add_developer(developer)
  end

  describe 'GET /projects/:id/deployments' do
    let(:project) { create(:project) }
    let!(:deployment_1) { create(:deployment, :success, project: project, iid: 11, ref: 'master', created_at: Time.now) }
    let!(:deployment_2) { create(:deployment, :success, project: project, iid: 12, ref: 'feature', created_at: 1.day.ago) }
    let!(:deployment_3) { create(:deployment, :success, project: project, iid: 8, ref: 'patch', created_at: 2.days.ago) }

    context 'as member of the project' do
      it 'returns projects deployments sorted by id asc' do
        get api("/projects/#{project.id}/deployments", developer)

        expect(response).to have_gitlab_http_status(200)
        expect(response).to include_pagination_headers
        expect(json_response).to be_an Array
        expect(json_response.size).to eq(3)
        expect(json_response.first['iid']).to eq(deployment_1.iid)
        expect(json_response.first['sha']).to match /\A\h{40}\z/
        expect(json_response.second['iid']).to eq(deployment_2.iid)
        expect(json_response.last['iid']).to eq(deployment_3.iid)
      end

      describe 'ordering' do
        let(:order_by) { nil }
        let(:sort) { nil }

        subject { get api("/projects/#{project.id}/deployments?order_by=#{order_by}&sort=#{sort}", developer) }

        def expect_deployments(ordered_deployments)
          json_response.each_with_index do |deployment_json, index|
            expect(deployment_json['id']).to eq(public_send(ordered_deployments[index]).id)
          end
        end

        before do
          subject
        end

        where(:order_by, :sort, :ordered_deployments) do
          'created_at' | 'asc'  | [:deployment_3, :deployment_2, :deployment_1]
          'created_at' | 'desc' | [:deployment_1, :deployment_2, :deployment_3]
          'id'         | 'asc'  | [:deployment_1, :deployment_2, :deployment_3]
          'id'         | 'desc' | [:deployment_3, :deployment_2, :deployment_1]
          'iid'        | 'asc'  | [:deployment_3, :deployment_1, :deployment_2]
          'iid'        | 'desc' | [:deployment_2, :deployment_1, :deployment_3]
          'ref'        | 'asc'  | [:deployment_2, :deployment_1, :deployment_3]
          'ref'        | 'desc' | [:deployment_3, :deployment_1, :deployment_2]
        end

        with_them do
          it 'returns the deployments ordered' do
            expect_deployments(ordered_deployments)
          end
        end
      end
    end

    context 'as non member' do
      it 'returns a 404 status code' do
        get api("/projects/#{project.id}/deployments", non_member)

        expect(response).to have_gitlab_http_status(404)
      end
    end
  end

  describe 'GET /projects/:id/deployments/:deployment_id' do
    let(:project)     { deployment.environment.project }
    let!(:deployment) { create(:deployment, :success) }

    context 'as a member of the project' do
      it 'returns the projects deployment' do
        get api("/projects/#{project.id}/deployments/#{deployment.id}", developer)

        expect(response).to have_gitlab_http_status(200)
        expect(json_response['sha']).to match /\A\h{40}\z/
        expect(json_response['id']).to eq(deployment.id)
      end
    end

    context 'as non member' do
      it 'returns a 404 status code' do
        get api("/projects/#{project.id}/deployments/#{deployment.id}", non_member)

        expect(response).to have_gitlab_http_status(404)
      end
    end
  end

  describe 'POST /projects/:id/deployments' do
    let!(:project) { create(:project, :repository) }
    let!(:environment) { create(:environment, project: project) }
    let(:sha) { 'b83d6e391c22777fca1ed3012fce84f633d7fed0' }

    where(:user_type, :expected_status) do
      :maintainer | 201
      :developer  | 201
      :non_member | 404
    end

    with_them do
      it 'matches the expected status' do
        post(
          api("/projects/#{project.id}/deployments", users[user_type]),
          params: {
            environment_id: environment.id,
            sha: sha,
            ref: 'master',
            tag: false,
            status: 'success'
          }
        )

        expect(response).to have_gitlab_http_status(expected_status)

        if expected_status == 201
          expect(json_response['sha']).to eq(sha)
          expect(json_response['ref']).to eq('master')
        end
      end
    end
  end

  describe 'PUT /projects/:id/deployments/:deployment_id' do
    let(:project) { create(:project) }
    let(:build) { create(:ci_build, :failed, project: project) }
    let(:environment) { create(:environment, project: project) }
    let(:deploy) do
      create(
        :deployment,
        :failed,
        project: project,
        deployable: build,
        environment: environment
      )
    end

    where(:user_type, :with_associated_build, :expected_status) do
      :maintainer | true  | 200
      :maintainer | false | 200
      :developer  | true  | 403
      :developer  | false | 200
      :non_member | true  | 404
      :non_member | false | 404
    end

    with_them do
      it 'matches the expected status' do
        deploy.update(deployable: nil) unless with_associated_build

        put(
          api("/projects/#{project.id}/deployments/#{deploy.id}", users[user_type]),
          params: { status: 'success' }
        )

        expect(response).to have_gitlab_http_status(expected_status)

        if expected_status == 200
          expect(json_response['status']).to eq('success')
        end
      end
    end
  end
end
