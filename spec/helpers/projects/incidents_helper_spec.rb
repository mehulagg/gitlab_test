# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IncidentsHelper do
  include Gitlab::Routing.url_helpers

  let(:project) { create(:project) }
  let(:project_path) { project.full_path }
  let(:new_issue_path) { new_project_issue_path(project) }
  let(:issue_path) { project_issues_path(project) }

  describe '#incidents_data' do
    subject(:data) { helper.incidents_data(project) }

    it 'returns frontend configuration' do
      expect(data).to match(
        'project-path' => project_path,
        'new-issue-path' => new_issue_path,
        'incident-template-name' => 'incident',
        'incident-type' => 'incident',
        'issue-path' => issue_path,
        'empty-list-svg-path' => match_asset_path('/assets/illustrations/incident-empty-state.svg'),
        'text-query': 'search',
        'author-usernames-query': 'root',
        'assignee-usernames-query': 'root'
      )
    end
  end
end
