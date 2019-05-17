# frozen_string_literal: true

require 'spec_helper'

describe 'rendering namespace statistics' do
  include GraphqlHelpers

  let(:group) { create(:group) }
  let(:project) { create(:project, namespace: group) }
  let!(:project_statistics) { create(:project_statistics, project: project, packages_size: 5.megabytes) }
  let(:user) { create(:user) }

  let(:query) do
    graphql_query_for('namespace',
                      { 'fullPath' => group.full_path },
                      "statistics { #{all_graphql_fields_for('NamespaceStatistics')} }")
  end

  before do
    group.add_owner(user)
  end

  it_behaves_like 'a working graphql query' do
    before do
      post_graphql(query, current_user: user)
    end
  end

  it "includes the packages size if the user can read the statistics" do
    post_graphql(query, current_user: user)

    expect(graphql_data['namespace']['statistics']['packagesSize']).to eq(5.megabytes)
  end

  it 'does not include statistics when the user is not allowed to read the statistics' do
    post_graphql(query, current_user: nil)

    expect(graphql_data['namespace']['statistics']).to be_nil
  end
end
