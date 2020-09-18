# frozen_string_literal: true

class CleanupContainerRepositoryLimitedCapacityWorker
  include ApplicationWorker
  include LimitedCapacity::Worker

  queue_namespace :container_repository
  feature_category :container_registry
  urgency :low
  worker_resource_boundary :unknown
  idempotent!
  loggable_arguments 2

  sidekiq_options queue: 'container_repository:cleanup_container_repository' # rubocop: disable Cop/SidekiqOptionsQueue

  private

  def perform_work
    return unless container_repository

    result = Projects::ContainerRepository::CleanupTagsService
      .new(project, nil, policy_params.merge(container_expiration_policy: true))
      .execute(container_repository)

    return if result[:status] == :success

    reenqueue_container_repository_id(container_repository.id)
  end

  def remaining_work_count
    Sidekiq.redis { |r| r.llen(ContainerExpirationPolicyWorker::CONTAINER_REPOSITORY_IDS_QUEUE) }
  end

  def max_running_jobs
    ::Gitlab::CurrentSettings.current_application_settings.container_registry_expiration_policies_capacity
  end

  def policy_params
    return {} unless project.container_expiration_policy

    project.container_expiration_policy.attributes.except('created_at', 'updated_at')
  end

  def project
    container_repository&.project
  end

  def container_repository
    ContainerRepository.find_by_id(container_repository_id)
  end

  def container_repository_id
    Sidekiq.redis { |r| r.lpop(ContainerExpirationPolicyWorker::CONTAINER_REPOSITORY_IDS_QUEUE) }
  end

  def reenqueue_container_repository_id(id)
    Sidekiq.redis { |r| r.rpush(ContainerExpirationPolicyWorker::CONTAINER_REPOSITORY_IDS_QUEUE, id) }
  end
end
