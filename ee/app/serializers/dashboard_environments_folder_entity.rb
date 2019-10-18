# frozen_string_literal: true

class DashboardEnvironmentsFolderEntity < Grape::Entity
  class DashboardEnvironmentDecorator
    attr_reader :raw_environment, :last_deployment

    delegate_missing_to :raw_environment

    def initialize(environment, last_deployment)
      @raw_environment = environment
      @last_deployment = last_deployment
    end
  end

  class DashboardLastDeploymentDecorator
    attr_reader :raw_last_deployment

    delegate_missing_to :raw_last_deployment

    def initialize(last_deployment)
      @raw_last_deployment = last_deployment
    end

    def last?
      true
    end
  end

  expose :last_environment, merge: true do |environment_folder, options|
    environment = environment_folder.last_environment
    deployment = options[:last_deployments][environment.id]
    decorated_deployment = DashboardLastDeploymentDecorator.new(deployment) unless deployment.nil?
    decorator = DashboardEnvironmentDecorator.new(environment, decorated_deployment)
    DashboardEnvironmentEntity.represent(decorator, options)
  end

  expose :size
  expose :within_folder?, as: :within_folder
end
