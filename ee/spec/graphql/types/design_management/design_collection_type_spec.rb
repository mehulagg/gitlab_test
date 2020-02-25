# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['DesignCollection'] do
  it { expect(described_class).to require_graphql_authorizations(:read_design) }

  it 'has the expected fields' do
    expected_fields = %i[project issue designs versions version designAtVersion design]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end

  describe 'pagination and totalCount' do
    let_it_be(:user) { create(:user) }
    let_it_be(:namespace) { create(:namespace, owner: user) }
    let_it_be(:project) { create(:project, :public, namespace: namespace) }
    let_it_be(:issue) { create(:issue, project: project) }
    let_it_be(:designs) { create_list(:design, 10, :with_versions, versions_count: 5, issue: issue) }
    let_it_be(:query) do
      <<~GRAPHQL
        query project($fullPath: ID!, $iid: String!, $atVersion: ID, $first: Int, $after: String) {
          project(fullPath: $fullPath) {
            id
            issue(iid: $iid) {
              iid
              designCollection {
                designs(atVersion: $atVersion, first: $first, after: $after) {
                  totalCount
                  edges {
                    node {
                      id
                    }
                  }
                  pageInfo {
                    endCursor
                    hasNextPage
                  }
                }
              }
            }
          }
        }
      GRAPHQL
    end

    before do
      allow(Ability).to receive(:allowed?).and_return(true)
    end

    let(:page_size) { 3 }

    subject do
      GitlabSchema.execute(
        query,
        context: { current_user: user },
        variables: {
          fullPath: project.full_path,
          iid: issue.iid.to_s,
          first: page_size
        }
      ).to_h
    end

    context 'totalCount' do
      it 'returns total count' do
        path = %w(data project issue designCollection designs totalCount)
        expect(subject.dig(*path)).to eq(designs.count)
      end

      it "total count does not change between pages" do
        old_count = subject.dig(*%w(data project issue designCollection designs totalCount))
        new_cursor = subject.dig(*%w(data project issue designCollection designs pageInfo endCursor))
        new_page = GitlabSchema.execute(
          query,
          context: { current_user: user },
          variables: {
            fullPath: project.full_path,
            iid: issue.iid.to_s,
            first: page_size,
            after: new_cursor
          }
        ).to_h
        new_count = new_page.dig(*%w(data project issue designCollection designs totalCount))
        expect(old_count).to eq(new_count)
      end

      context 'pagination' do
        let(:page_size) { 9 }

        it 'returns new ids during pagination' do
          old_edges = subject.dig(*%w(data project issue designCollection designs edges))
          new_cursor = subject.dig(*%w(data project issue designCollection designs pageInfo endCursor))
          new_page = GitlabSchema.execute(
            query,
            context: { current_user: user },
            variables: {
              fullPath: project.full_path,
              iid: issue.iid.to_s,
              first: page_size,
              after: new_cursor
            }
          ).to_h
          new_edges = new_page.dig(*%w(data project issue designCollection designs edges))
          expect(old_edges.count).to eq(9)
          expect(new_edges.count).to eq(1)
        end
      end
    end
  end
end
