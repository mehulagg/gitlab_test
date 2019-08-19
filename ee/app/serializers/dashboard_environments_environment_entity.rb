# frozen_string_literal: true

class DashboardEnvironmentsEnvironmentEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :name
  expose :size
  expose :within_folder
  expose :external_url
  expose :environment_path do |environment|
    project_environment_path(environment.project, environment.raw_environment)
  end
  expose :last_deployment do |environment|
    DeploymentEntity.represent(environment.last_deployment, options.merge(request: new_request))
  end

  private

  alias_method :environment, :object

  def new_request
    EntityRequest.new(
      current_user: request.current_user,
      project: environment.project
    )
  end
end
