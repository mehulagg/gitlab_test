# frozen_string_literal: true

class DashboardEnvironmentsEnvironmentEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :name
  expose :size
  expose :within_folder do |environment|
    environment.size > 1 || environment.environment_type.present?
  end
  expose :external_url
  expose :environment_path do |environment|
    project_environment_path(environment.project, environment)
  end
end
