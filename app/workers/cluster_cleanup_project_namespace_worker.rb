# frozen_string_literal: true

# This worker asynchronously deletes all project namespaces from cluster in
# batches. Only after the a batch is finished,
# the workers is called again to remove the next batch.
#
# This worker has also an execution count limit. If it reaches the limit, it
# sets the cluster.cleanup_status as errored.

class ClusterCleanupProjectNamespaceWorker < ClusterCleanupWorkerBase
  include ApplicationWorker
  include ClusterQueue

  KUBERNETES_NAMESPACE_BATCH_SIZE = 100

  def perform(cluster_id, execution_count = 0)
    super(cluster_id, execution_count)

    return exceeded_execution_limit if exceeded_execution_limit?

    delete_project_namespaces_in_batches

    return schedule_next_execution if cluster.kubernetes_namespaces.exists?

    cluster.continue_cleanup!
  end

  private

  def delete_project_namespaces_in_batches
    kubernetes_namespaces_batch = cluster.kubernetes_namespaces.first(KUBERNETES_NAMESPACE_BATCH_SIZE)

    kubernetes_namespaces_batch.each do |kubernetes_namespace|
      log_event(:deleting_project_namespace, namespace: kubernetes_namespace.namespace)

      kubeclient_delete_namespace(kubernetes_namespace)
    end
  end

  def kubeclient_delete_namespace(kubernetes_namespace)
    cluster.kubeclient.delete_namespace(kubernetes_namespace.namespace)
  rescue Kubeclient::ResourceNotFoundError
  ensure
    kubernetes_namespace.destroy
  end
end
