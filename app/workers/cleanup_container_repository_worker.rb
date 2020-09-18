# frozen_string_literal: true

class CleanupContainerRepositoryWorker
  include ApplicationWorker

  queue_namespace :container_repository
  feature_category :container_registry
  urgency :low
  worker_resource_boundary :unknown
  idempotent!
  loggable_arguments 2

  deduplicate :until_executing, including_scheduled: true

  attr_reader :container_repository, :current_user

  def perform(current_user_id, container_repository_id, params)
    @current_user = User.find_by_id(current_user_id)
    @container_repository = ContainerRepository.find_by_id(container_repository_id)
    @params = params

    return unless valid?

    if run_by_container_expiration_policy?
      params.merge!(params_from_container_expiration_policy)
    end

    result = Projects::ContainerRepository::CleanupTagsService
      .new(project, current_user, params)
      .execute(container_repository)

    if run_by_container_expiration_policy? && result[:status] == :success
      container_repository.reset_expiration_policy_started_at!
    end

  ensure
    remove_from_redis
  end

  private

  def valid?
    return true if run_by_container_expiration_policy?

    current_user && container_repository && project
  end

  def run_by_container_expiration_policy?
    container_expiration_policy && container_repository.present? && project.present?
  end

  def params_from_container_expiration_policy
    return {} unless project.container_expiration_policy

    project.container_expiration_policy.attributes.except('created_at', 'updated_at')
  end

  def remove_from_redis
    return unless throttling_enabled? && jids_redis_key.present?

    # Remove jid from array stored in jids_redis_key
    Sidekiq.redis do |redis|
      redis.srem(jids_redis_key, jid)
    end
  end

  def throttling_enabled?
    Feature.enabled?(:container_registry_expiration_policies_throttling)
  end

  def project
    container_repository&.project
  end

  def container_expiration_policy
    @params['container_expiration_policy']
  end

  def jids_redis_key
    @params['jids_redis_key']
  end
end
