# frozen_string_literal: true

module API
  module Entities
    module JobRequest
      class Response < Grape::Entity
        expose :id
        expose :token
        expose :allow_git_fetch

        expose :job_info, using: Entities::JobRequest::JobInfo do |model|
          model
        end

        expose :git_info, using: Entities::JobRequest::GitInfo do |model|
          model
        end

        expose :runner_info, using: Entities::JobRequest::RunnerInfo do |model|
          model
        end

        expose :variables
        expose :steps, using: Entities::JobRequest::Step
        expose :image, using: Entities::JobRequest::Image
        expose :services, using: Entities::JobRequest::Service
        expose :artifacts, using: Entities::JobRequest::Artifacts
        expose :cache, using: Entities::JobRequest::Cache
        expose :credentials, using: Entities::JobRequest::Credentials
        expose :dependencies_from_cache, as: :dependencies, using: Entities::JobRequest::Dependency
        expose :features
      end
    end
  end
end
