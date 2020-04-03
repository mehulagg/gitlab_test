# frozen_string_literal: true

require 'spec_helper'

describe 'Jira import scheduling', :js do
  let_it_be(:user)    { create(:user) }
  let_it_be(:project) { create(:project) }
  let(:jira_projects) { [] }

  before do
    stub_feature_flags(jira_issue_import: true)
    allow(JIRA::Resource::Project).to receive(:all).and_return(jira_projects)

    project.add_maintainer(user)

    sign_in(user)
    visit project_import_jira_path(project)

    wait_for_requests
  end

  context 'when Jira configuration is missing' do
    it 'displays an error message' do
      expect(page).to have_content('Configure the Jira integration first')
    end
  end

  context 'when Jira is configured correctly' do
    let_it_be(:jira_service) { create(:jira_service, project: project) }

    context 'when Jira does not return any projects' do
      it 'displays an error message' do
        expect(page).to have_content('No projects have been returned from Jira. Please check your Jira configuration.')
      end
    end

    context 'when Jira returns projects' do
      let(:jira_projects) { [double(name: 'FOO project', key: 'FOO'), double(name: 'Test project', key: 'TEST')] }

      it 'lets user to schedule the import and provides correct feedback' do
        find('.content form .select2').click

        wait_for_requests

        expect(find('.select2-results')).to have_content('FOO project (FOO')
        expect(find('.select2-results')).to have_content('Test project (TEST')

        page.within('.select2-results') do
          first('.select2-result-label').click
        end

        click_on 'Import issues'

        wait_for_requests

        expect(page).to have_content('Import scheduled')
      end
    end
  end
end
