# frozen_string_literal: true

class ContainerExpirationPolicyWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue
  include Gitlab::Utils::StrongMemoize

  feature_category :container_registry

  InvalidPolicyError = Class.new(StandardError)

  CONTAINER_REPOSITORY_IDS_QUEUE = 'container_expiration_policies:container_repository_ids'

  def perform
    throttling_enabled? ? perform_throttled : perform_unthrottled
  end

  private

  def perform_unthrottled
    runnable_policies.each do |container_expiration_policy|
      with_context(project: container_expiration_policy.project,
                   user: container_expiration_policy.project.owner) do |project:, user:|
        ContainerExpirationPolicyService.new(project, user)
                                        .execute(container_expiration_policy)
      end
    end
  end

  def perform_throttled
    runnable_policies.each(&:schedule_next_run!)

    container_repository_ids = ContainerRepository.for_project(runnable_policies.select(:project_id))
                                                  .pluck_primary_key
    enqueue_in_redis(container_repository_ids)

    CleanupContainerRepositoryLimitedCapacityWorker.perform_with_capacity
  end

  def runnable_policies
    valid, invalid = ContainerExpirationPolicy.runnable_schedules
                                              .preloaded
                                              .partition { |policy| policy.valid? }

    invalid.each do |policy|
      policy.disable!
      Gitlab::ErrorTracking.log_exception(
        ::ContainerExpirationPolicyWorker::InvalidPolicyError.new,
        container_expiration_policy_id: policy.id
      )
    end

    ContainerExpirationPolicy.for_project_id(valid.map(&:project_id))
  end

  def enqueue_in_redis(container_repository_ids)
    Sidekiq.redis { |r| r.lpush(CONTAINER_REPOSITORY_IDS_QUEUE, container_repository_ids) }
  end
end
