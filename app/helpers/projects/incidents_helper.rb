# frozen_string_literal: true

module Projects::IncidentsHelper
  def incidents_data(project, params)
    {
      'project-path' => project.full_path,
      'new-issue-path' => new_project_issue_path(project),
      'incident-template-name' => 'incident',
      'incident-type' => 'incident',
      'empty-list-svg-path' => image_path('illustrations/incident-empty-state.svg'),
      'text-query': params[:search],
      'author-usernames-query': params[:author_username],
      'assignee-usernames-query': params[:assignee_username]
    }
  end
end

Projects::IncidentsHelper.prepend_if_ee('EE::Projects::IncidentsHelper')
