# frozen_string_literal: true

require 'spec_helper'

describe ClusterCleanupServiceAccountWorker do
  describe '#perform' do
    subject { worker_instance.perform(cluster.id) }

    let!(:worker_instance) { described_class.new }
    let!(:cluster) { create(:cluster, :removing_service_account) }
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
    end

    it 'deletes gitlab service account' do
      expect(kubeclient_intance_double).to receive(:delete_service_account)
        .with(
          ::Clusters::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAME,
          ::Clusters::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAMESPACE)

      subject
    end

    it 'deletes cluster' do
      expect { subject }.to change { Clusters::Cluster.where(id: cluster.id).exists? }.from(true).to(false)
    end
  end
end
