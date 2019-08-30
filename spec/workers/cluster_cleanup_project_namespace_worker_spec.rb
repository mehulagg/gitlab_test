# frozen_string_literal: true

require 'spec_helper'

describe ClusterCleanupProjectNamespaceWorker do
  describe '#perform' do
    subject { worker_instance.perform(cluster.id) }

    let!(:worker_instance) { described_class.new }
    let!(:cluster) { create(:cluster, :with_environments, :removing_project_namespaces) }
    let!(:logger) { worker_instance.send(:logger) }
    let(:log_meta) do
      {
        service: described_class.name,
        cluster_id: cluster.id,
        execution_count: 0
      }
    end
    let(:kubeclient_intance_double) do
      instance_double(Gitlab::Kubernetes::KubeClient, delete_namespace: nil, delete_service_account: nil)
    end

    before do
      allow_any_instance_of(Clusters::Cluster).to receive(:kubeclient).and_return(kubeclient_intance_double)
      allow(ClusterCleanupServiceAccountWorker).to receive(:perform_async)
    end

    context 'when cluster has namespaces to be deleted' do
      it 'deletes namespaces from cluster' do
        expect(kubeclient_intance_double).to receive(:delete_namespace)
          .with cluster.kubernetes_namespaces[0].namespace
        expect(kubeclient_intance_double).to receive(:delete_namespace)
          .with(cluster.kubernetes_namespaces[1].namespace)

        subject
      end

      it 'deletes namespaces from database' do
        expect { subject }.to change { cluster.kubernetes_namespaces.exists? }.from(true).to(false)
      end

      it 'schedules ClusterCleanupServiceAccountWorker' do
        expect(ClusterCleanupServiceAccountWorker).to receive(:perform_async).with(cluster.id)
        subject
      end

      it 'logs all events' do
        expect(logger).to receive(:info)
          .with(
            log_meta.merge(
              event: :deleting_project_namespace,
              namespace: cluster.kubernetes_namespaces[0].namespace))
        expect(logger).to receive(:info)
          .with(
            log_meta.merge(
              event: :deleting_project_namespace,
              namespace: cluster.kubernetes_namespaces[1].namespace))

        subject
      end
    end

    context 'when cluster has no namespaces' do
      let!(:cluster) { create(:cluster, :removing_project_namespaces) }

      it 'schedules ClusterCleanupServiceAccountWorker' do
        expect(ClusterCleanupServiceAccountWorker).to receive(:perform_async).with(cluster.id)

        subject
      end

      it 'transitions to removing_service_account' do
        expect { subject }
          .to change { cluster.reload.cleanup_status_name }
          .from(:removing_project_namespaces)
          .to(:removing_service_account)
      end

      it 'does not try to delete namespaces' do
        expect(kubeclient_intance_double).not_to receive(:delete_namespace)

        subject
      end
    end

    context 'when exceeded the execution limit' do
      subject { worker_instance.perform(cluster.id, worker_instance.send(:execution_limit)) }

      let(:worker_instance) { described_class.new }
      let(:logger) { worker_instance.send(:logger) }

      it 'logs the error' do
        expect(logger).to receive(:error)
          .with(
            hash_including(
              exception: 'ClusterCleanupWorkerBase::ExceededExecutionLimitError',
              cluster_id: kind_of(Integer),
              class_name: described_class.name,
              event: :failed_to_remove_cluster_and_resources,
              message: 'retried too many times'
            )
          )

        subject
      end
    end
  end
end
