# frozen_string_literal: true

class DashboardEnvironmentsProjectEntity < Grape::Entity
  include RequestAwareEntity

  expose :project, merge: true, using: API::Entities::BasicProjectDetails

  expose :remove_path do |dashboard_project_object|
    remove_operations_project_path(project_id: dashboard_project_object.project.id)
  end

  expose :environments do |dashboard_project, options|
    dashboard_project.project.environments.map do |environment|
      DashboardEnvironmentsEnvironmentEntity.represent(environment, options.merge(request: new_request))
    end
  end

  private

  alias_method :dashboard_project, :object

  def new_request
    EntityRequest.new(
      current_user: request.current_user,
      project: dashboard_project.project
    )
  end

  def last_pipeline
    dashboard_project.project.last_pipeline
  end

  def last_deployment?
    dashboard_project.last_deployment
  end

  def last_alert?
    dashboard_project.last_alert
  end
end
