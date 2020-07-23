# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'get list of boards' do
  include GraphqlHelpers

  include_context 'group and project boards query context'

  before do
    stub_licensed_features(multiple_group_issue_boards: true)
  end

  describe 'for a group' do
    let(:board_parent) { create(:group, :private) }

    it_behaves_like 'group and project boards query'
  end

  context 'with user preferences' do
    let(:board_parent) { create(:group, :private) }

    it 'returns current user preferences for board' do
      board_parent.add_developer(current_user)
      board = create(:board, resource_parent: board_parent, name: 'a')
      create(:board_user_preference, user: current_user, board: board, hide_labels: true)

      post_graphql(query_single_board("id: \"#{global_id_of(board)}\""), current_user: current_user)

      expect(board_data['userPreferences']['hideLabels']).to eq(true)
    end
  end
end
