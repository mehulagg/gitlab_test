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
end
