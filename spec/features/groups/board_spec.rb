# frozen_string_literal: true

require 'spec_helper'

describe 'Group Boards', :js do
  let(:group) { create(:group) }
  let(:user) { create(:group_member, :maintainer, user: create(:user), group: group ).user }

  before do
    stub_licensed_features(multiple_group_issue_boards: true)
    sign_in(user)
    visit group_boards_path(group)
    wait_for_requests
  end

  context 'Creates a an issue' do
    let!(:project) { create(:project_empty_repo, group: group) }

    it 'Adds an issue to the backlog' do
      page.within(find('.board', match: :first)) do
        issue_title = 'New Issue'
        find(:css, '.issue-count-badge-add-button').click
        expect(find('.board-new-issue-form')).to be_visible

        fill_in 'issue_title', with: issue_title
        find('.dropdown-menu-toggle').click

        wait_for_requests

        click_link(project.name)
        click_button 'Submit issue'

        expect(page).to have_content(issue_title)
      end
    end
  end

  context 'Group board deletion' do
    before do
      @new_board = create(:board, group: group, name: 'New board')
    end

    it 'Deletes a group issue board' do
      find(:css, '.js-dropdown-toggle').click
      wait_for_requests
      find(:css, '.js-delete-board button').click
      find(:css, '.board-config-modal .js-primary-button').click

      wait_for_requests

      find(:css, '.js-dropdown-toggle').click

      expect(page).not_to have_content('Development')
      expect(page).to have_content(@new_board.name)
    end
  end
end
