# frozen_string_literal: true

class ClusterCleanupWorkerBase
  # The maximum amount of times this job is called for the same cluster, before
  # giving up and logging an ExceededExecutionLimitError.
  DEFAULT_EXECUTION_LIMIT = 10

  # The amount of time to wait when scheduling the next execution.
  DEFAULT_EXECUTION_INTERVAL = 20.seconds
  ExceededExecutionLimitError = Class.new(StandardError)

  def perform(cluster_id, execution_count = 0)
    @cluster_id = cluster_id
    @execution_count = execution_count
  end

  private

  # Override this method if you'd like to load you cluster another way.
  def cluster
    @cluster ||= Clusters::Cluster.find_by_id(@cluster_id)
  end

  def log_event(event, extra_data = {})
    meta = {
      service: self.class.name,
      cluster_id: @cluster_id,
      execution_count: @execution_count,
      event: event
    }

    logger.info(meta.merge(extra_data))
  end

  # Override this method to customize the execution_limit
  def execution_limit
    DEFAULT_EXECUTION_LIMIT
  end

  # Override this method to customize the execution interval
  def execution_interval
    DEFAULT_EXECUTION_INTERVAL
  end

  def exceeded_execution_limit?
    @execution_count >= execution_limit
  end

  def schedule_next_execution
    log_event(:scheduling_execution, next_execution: @execution_count + 1)

    self.class.perform_in(execution_interval, @cluster_id, @execution_count + 1)
  end

  def logger
    @logger ||= Gitlab::Kubernetes::Logger.build
  end

  def exceeded_execution_limit
    log_exceeded_execution_limit_error

    cluster.make_cleanup_errored!("#{self.class.name} exceeded the execution limit")
  end

  def log_exceeded_execution_limit_error
    logger.error({
      exception: ExceededExecutionLimitError.name,
      cluster_id: @cluster_id,
      class_name: self.class.name,
      event: :failed_to_remove_cluster_and_resources,
      message: "retried too many times"
      })
  end

  def kubeclient
    cluster.kubeclient
  end
end
