# frozen_string_literal: true

RSpec.shared_examples 'group and project boards query' do
  include GraphqlHelpers

  it_behaves_like 'a working graphql query' do
    before do
      post_graphql(query, current_user: current_user)
    end
  end

  context 'when the user does not have access to the board parent' do
    it 'returns nil' do
      create(:board, resource_parent: board_parent, name: 'A')

      post_graphql(query)

      expect(graphql_data[board_parent_type]).to be_nil
    end
  end

  context 'when user can read the board parent' do
    before do
      board_parent.add_reporter(user)
    end

    it 'does not create a default board' do
      post_graphql(query, current_user: current_user)

      expect(boards_data).to be_empty
    end

    describe 'sorting and pagination' do
      context 'when using default sorting' do
        let!(:board_B) { create(:board, resource_parent: board_parent, name: 'B') }
        let!(:board_C) { create(:board, resource_parent: board_parent, name: 'C') }
        let!(:board_a) { create(:board, resource_parent: board_parent, name: 'a') }
        let!(:board_A) { create(:board, resource_parent: board_parent, name: 'A') }

        before do
          post_graphql(query, current_user: current_user)
        end

        it_behaves_like 'a working graphql query'

        context 'when ascending' do
          it 'sorts boards' do
            if board_parent.multiple_issue_boards_available?
              expect(grab_names).to eq [board_a.name, board_A.name, board_B.name, board_C.name]
            else
              expect(grab_names).to eq [board_a.name]
            end
          end

          context 'when paginating' do
            let(:params) { 'first: 2' }

            it 'sorts issues' do
              if board_parent.multiple_issue_boards_available?
                expect(grab_names).to eq [board_a.name, board_A.name]
              else
                expect(grab_names).to eq [board_a.name]
              end

              cursored_query = query("after: \"#{end_cursor}\"")
              post_graphql(cursored_query, current_user: current_user)

              response_data = JSON.parse(response.body)['data'][board_parent_type]['boards']['edges']

              if board_parent.multiple_issue_boards_available?
                expect(grab_names(response_data)).to eq [board_B.name, board_C.name]
              else
                expect(grab_names(response_data)).to be_empty
              end
            end
          end
        end
      end
    end
  end
end
