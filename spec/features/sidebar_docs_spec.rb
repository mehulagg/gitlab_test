# frozen_string_literal: true

require 'spec_helper'

describe 'DocTest' do
  def screenshot_element(page, element_selector, path)
    x = page.evaluate_script("document.querySelector('#{element_selector}').getBoundingClientRect().x")
    y = page.evaluate_script("document.querySelector('#{element_selector}').getBoundingClientRect().y")
    height = page.evaluate_script("document.querySelector('#{element_selector}').getBoundingClientRect().height")
    width = page.evaluate_script("document.querySelector('#{element_selector}').getBoundingClientRect().width")

    screenshot_path = Tempfile.new(%w[screenshot png])
    page.save_screenshot(screenshot_path.path, full: true)
    screenshot = MiniMagick::Image.open(screenshot_path.path)
    screenshot.crop("#{width}x#{height}+#{x}+#{y}")
    screenshot.write(Rails.root.join(path))
  end

  context 'group insights navbar', :js do
    it 'takes screenshot of group insights navbar with contribution analytics selected' do
      user = create(:user)
      group = create(:group)

      stub_licensed_features(insights: true)
      group.add_maintainer(user)

      sign_in(user)

      visit group_insights_path(group)

      screenshot_element(page, '.sidebar-top-level-items > li.active', 'doc/user/group/insights/img/insights_sidebar_link.png')
    end
  end

  context 'project access request', :js do
    it 'takes screenshot of a project access request' do
      requester = create(:user, username: 'johnd', name: 'John Doe')
      maintainer = create(:user)

      group = create(:group, name: 'gitlab-org')
      project = create(:project, name: 'gitlab', group: group)
      project.add_maintainer(maintainer)

      create(:project_member, :access_request, user: requester, project: project)

      sign_in(maintainer)

      visit project_project_members_path(project)

      screenshot_element(page, '.card.prepend-top-default', 'doc/user/group/img/access_requests_management.png')
    end
  end
end
