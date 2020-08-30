# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Reposition and move issue within board lists' do
  include GraphqlHelpers

  let_it_be(:group)   { create(:group, :private) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:board)   { create(:board, group: group) }
  let_it_be(:user)    { create(:user) }
  let_it_be(:epic)    { create(:epic, group: group) }
  let_it_be(:development) { create(:label, project: project, name: 'Development') }
  let_it_be(:testing) { create(:label, project: project, name: 'Testing') }
  let_it_be(:list1)   { create(:list, board: board, label: development, position: 0) }
  let_it_be(:list2)   { create(:list, board: board, label: testing, position: 1) }
  let_it_be(:issue1) { create(:labeled_issue, project: project, labels: [development]) }
  let(:params) { { board_id: board.to_global_id.to_s, project_path: project.full_path, iid: issue1.iid.to_s, epic_id: epic.to_global_id.to_s } }
  let(:current_user) { user }
  let(:issue_move_params) do
    {
      from_list_id: list1.id,
      to_list_id: list2.id
    }
  end

  let(:mutation) do
    graphql_mutation(
      :issue_move_list, params.merge(issue_move_params),
      <<~GRAPHQL
        clientMutationId
        errors
        issue {
          iid
          relativePosition
          labels {
            edges {
              node{
                title
              }
            }
          }
          epic {
            iid
            title
          }
        }
      GRAPHQL
    )
  end

  context 'when user has access to resources' do
    context 'when moving an issue to a different list and assigning a new epic' do
      let(:issue_move_params) { { from_list_id: list1.id, to_list_id: list2.id } }

      before do
        group.add_developer(user)
        stub_licensed_features(epics: true)
      end

      it 'moves issue to a different list and assign new epic' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(response).to have_gitlab_http_status(:success)
        response_issue = json_response['data']['issueMoveList']['issue']
        expect(response_issue['iid']).to eq(issue1.iid.to_s)
        expect(response_issue['labels']['edges'][0]['node']['title']).to eq(testing.title)
        expect(response_issue['epic']['iid']).to eq(epic.iid)
      end
    end
  end
end
