# frozen_string_literal: true

# This is the final step of removing a cluster.
# It deletes ::Clusters::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAME from the cluster,
# then deletes the cluster from the database

class ClusterCleanupServiceAccountWorker < ClusterCleanupWorkerBase
  include ApplicationWorker
  include ClusterQueue

  def perform(cluster_id, execution_count = 0)
    super(cluster_id, execution_count)

    delete_gitlab_service_account

    cluster.destroy!
  end

  private

  def delete_gitlab_service_account
    log_event(:deleting_gitlab_service_account)

    cluster.kubeclient.delete_service_account(
      ::Clusters::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAME,
      ::Clusters::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAMESPACE
    )
  rescue Kubeclient::ResourceNotFoundError
  end
end
