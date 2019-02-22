require 'rails_helper'

describe 'Search bar', :js do
  let!(:project) { create(:project) }
  let!(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)
    create(:issue, project: project)

    visit project_issues_path(project)
  end

  it 'has a weight item' do
    find('.filtered-search').click

    find('#js-dropdown-hint .filter-dropdown .filter-dropdown-item', match: :first)

    expect(page).to have_selector('.weight')
  end
end
