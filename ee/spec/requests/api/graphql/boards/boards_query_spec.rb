# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'get list of boards' do
  include GraphqlHelpers

  include_context 'group and project boards query context'

  let_it_be(:parent_group) { create(:group) }
  let_it_be(:label) { create(:group_label, group: parent_group) }

  before do
    stub_licensed_features(multiple_group_issue_boards: true, epics: true)
  end

  shared_examples 'a board epics query' do
    before do
      parent_group.add_developer(current_user)
    end

    def board_epic_query(board)
      epic_query = <<~EPIC
        epics(issueFilters: {labelName: "#{label.title}", not: {authorUsername: "#{current_user.username}"}}) {
          nodes {
            id
            title
          }
        }
      EPIC

      graphql_query_for(
        board_parent_type,
        { 'fullPath' => board_parent.full_path },
        query_graphql_field(
          'board', { id: global_id_of(board) },
          epic_query
        )
      )
    end

    it 'returns open epics referenced by issues in the board' do
      board = create(:board, resource_parent: board_parent)
      issue_project = board_parent.is_a?(Project) ? board_parent : create(:project, group: board_parent)
      issue1 = create(:issue, project: issue_project, labels: [label])
      issue2 = create(:issue, project: issue_project, labels: [label])
      issue3 = create(:issue, project: issue_project)
      issue4 = create(:issue, project: issue_project, labels: [label])
      issue5 = create(:issue, project: issue_project, labels: [label], author: current_user)
      epic1 = create(:epic, group: parent_group)
      epic2 = create(:epic, group: parent_group)
      epic3 = create(:epic, :closed, group: parent_group)
      create(:epic_issue, issue: issue1, epic: epic1)
      create(:epic_issue, issue: issue2, epic: epic1)
      create(:epic_issue, issue: issue3, epic: epic2)
      create(:epic_issue, issue: issue4, epic: epic3)
      create(:epic_issue, issue: issue5, epic: epic2)

      post_graphql(board_epic_query(board), current_user: current_user)

      board_titles = board_data['epics']['nodes'].map { |node| node['title'] }
      expect(board_titles).to match_array [epic1.title]
    end
  end

  describe 'for a project' do
    let_it_be(:board_parent) { create(:project, group: parent_group) }

    it_behaves_like 'a board epics query'
  end

  describe 'for a group' do
    let_it_be(:board_parent) { create(:group, :private, parent: parent_group) }

    it_behaves_like 'group and project boards query'
    it_behaves_like 'a board epics query'
  end
end
