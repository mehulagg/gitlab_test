# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).dastSiteProfile' do
  include GraphqlHelpers

  let_it_be(:dast_site_profile) { create(:dast_site_profile) }
  let_it_be(:project) { dast_site_profile.project }
  let_it_be(:current_user) { create(:user) }

  let(:query) do
    %(
      query project($fullPath: ID!, $id: DastSiteProfileID!) {
        project(fullPath: $fullPath) {
          dastSiteProfile(id: $id) {
            id
            profileName
            targetUrl
            validationStatus
          }
        }
      }
    )
  end

  let(:project_response) { subject.dig('project') }
  let(:dast_site_profile_response) { project_response.dig('dastSiteProfile') }

  subject do
    post_graphql(
      query,
      current_user: current_user,
      variables: {
        fullPath: project.full_path,
        id: dast_site_profile.to_global_id.to_s
      }
    )
    graphql_data
  end

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  context 'when a user does not have access to the project' do
    it 'returns a null project' do
      expect(project_response).to be_nil
    end
  end

  context 'when a user does not have access to dast_site_profiles' do
    it 'returns a null dast_site_profile' do
      project.add_guest(current_user)

      expect(dast_site_profile_response).to be_nil
    end
  end

  context 'when a user has access to dast_site_profiles' do
    before do
      project.add_developer(current_user)
    end

    it 'returns a dast_site_profile' do
      expect(dast_site_profile_response['id']).to eq(dast_site_profile.to_global_id.to_s)
    end

    context 'when the wrong type of global id is supplied' do
      it 'returns a null dast_site_profile' do
        post_graphql(
          query,
          current_user: current_user,
          variables: {
            fullPath: project.full_path,
            id: project.to_global_id.to_s
          }
        )

        expected_message = 'Variable $id of type DastSiteProfileID! was provided invalid value'

        expect(graphql_errors[0]).to include('message' => expected_message)
      end
    end

    context 'when on demand scan feature flag is disabled' do
      it 'returns a null dast_site_profile' do
        stub_feature_flags(security_on_demand_scans_feature_flag: false)

        expect(dast_site_profile_response).to be_nil
      end
    end

    context 'when on demand scan licensed feature is not available' do
      it 'returns a null dast_site_profile' do
        stub_licensed_features(security_on_demand_scans: false)

        expect(dast_site_profile_response).to be_nil
      end
    end
  end
end
