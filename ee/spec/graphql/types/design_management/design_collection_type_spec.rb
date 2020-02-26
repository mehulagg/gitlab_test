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
            issue(iid: $iid) {
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

    context 'when user does not have the permission' do
      before do
        allow(Ability).to receive(:allowed?).and_return(true)
      end

      it 'returns total count as 0' do
        expect(subject.dig(*total_count_path)).to eq(0)
      end
    end

    context 'totalCount' do
      let_it_be(:total_count_path) { %w(data project issue designCollection designs totalCount) }
      let_it_be(:end_cursor) { %w(data project issue designCollection designs pageInfo endCursor) }
      let_it_be(:designs_edges) { %w(data project issue designCollection designs edges) }

      it 'returns total count' do
        expect(subject.dig(*total_count_path)).to eq(designs.count)
      end

      it 'total count does not change between pages' do
        old_count = subject.dig(*total_count_path)
        new_cursor = subject.dig(*end_cursor)

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

        new_count = new_page.dig(*total_count_path)
        expect(old_count).to eq(new_count)
      end

      context 'pagination' do
        let(:page_size) { 9 }

        it 'returns new ids during pagination' do
          old_edges = subject.dig(*designs_edges)
          new_cursor = subject.dig(*end_cursor)

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

          new_edges = new_page.dig(*designs_edges)
          expect(old_edges.count).to eq(9)
          expect(new_edges.count).to eq(1)
        end
      end
    end
  end
end
