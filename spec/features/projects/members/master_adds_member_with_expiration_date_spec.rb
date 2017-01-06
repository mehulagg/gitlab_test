require 'spec_helper'

feature 'Projects > Members > Master adds member with expiration date', feature: true, js: true do
  include WaitForAjax
  include Select2Helper
  include ActiveSupport::Testing::TimeHelpers

  let(:master) { create(:user) }
  let(:project) { create(:project) }
  let!(:new_member) { create(:user) }

  background do
    project.team << [master, :master]
    login_as(master)
  end

  scenario 'expiration date is displayed in the members list' do
    date = 5.days.from_now
    visit namespace_project_project_members_path(project.namespace, project)

    page.within '.users-project-form' do
      select2(new_member.id, from: '#user_ids', multiple: true)
      fill_in 'expires_at', with: date.to_s(:medium)
      click_on 'Add to project'
    end

    page.within "#project_member_#{new_member.project_members.first.id}" do
      expect(page).to have_content('Expires in 4 days')
    end
  end

  scenario 'change expiration date' do
    date = 4.days.from_now
    project.team.add_users([new_member.id], :developer, expires_at: Date.today.to_s(:medium))
    visit namespace_project_project_members_path(project.namespace, project)

    page.within "#project_member_#{new_member.project_members.first.id}" do
      find('.js-access-expiration-date').set date.to_s(:medium)
      wait_for_ajax
      expect(page).to have_content('Expires in 3 days')
    end
  end
end
