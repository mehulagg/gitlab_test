# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['DastSiteProfile'] do
  let_it_be(:dast_site_profile) { create(:dast_site_profile) }
  let_it_be(:project) { dast_site_profile.project }
  let_it_be(:user) { create(:user) }
  let_it_be(:fields) { %i[id profileName targetUrl validationStatus] }

  subject do
    GitlabSchema.execute(
      query,
      context: {
        current_user: user
      },
      variables: {
        fullPath: project.full_path,
        first: 1
      }
    ).as_json
  end

  it { expect(described_class).to have_graphql_fields(fields) }

  describe 'dast_site_profiles' do
    before do
      project.add_developer(user)
    end

    let(:query) do
      %(
        query project($fullPath: ID!, $first: Int, $after: String){
          project(fullPath: $fullPath) {
            dastSiteProfiles(first: $first, after: $after) {
              pageInfo {
                hasNextPage,
                hasPreviousPage
              }
              edges {
                cursor
                node {
                  id,
                  profileName,
                  targetUrl,
                  validationStatus
                }
              }
            }
          }
        }
      )
    end

    let(:first_dast_site_profile) do
      subject.dig('data', 'project', 'dastSiteProfiles', 'edges', 0, 'node')
    end

    describe 'id field' do
      it 'is a global id' do
        expect(first_dast_site_profile['id']).to eq(dast_site_profile.to_global_id.to_s)
      end
    end

    describe 'profile_name field' do
      it 'is the name' do
        expect(first_dast_site_profile['profileName']).to eq(dast_site_profile.name)
      end
    end

    describe 'target_url field' do
      it 'is the url of the associated dast_site' do
        expect(first_dast_site_profile['targetUrl']).to eq(dast_site_profile.dast_site.url)
      end
    end

    describe 'validation_status field' do
      it 'is the url of the associated dast_site' do
        expect(first_dast_site_profile['validationStatus']).to eq('PENDING_VALIDATION')
      end
    end
  end
end
