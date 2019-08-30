# frozen_string_literal: true

require 'spec_helper'

describe ClusterCleanupAppWorker do
  describe '#perform' do
    subject { worker_instance.perform(cluster.id) }

    let!(:worker_instance) { described_class.new }
    let!(:cluster) { create(:cluster, :project, :uninstalling_applications, provider_type: :gcp) }
    let!(:logger) { worker_instance.send(:logger) }
    let(:log_meta) do
      {
        service: described_class.name,
        cluster_id: cluster.id,
        execution_count: 0
      }
    end

    before do
      allow(ClusterCleanupProjectNamespaceWorker).to receive(:perform_async)
    end

    shared_examples 'does not reschedule itself' do
      it 'does not reschedule itself' do
        expect(described_class).not_to receive(:perform_in)
      end
    end

    context 'cluster is not uninstalling_applications' do
      it_behaves_like 'does not reschedule itself'
    end

    context 'when cluster has no applications available or transitioning applications' do
      it 'transitions cluster to removing_project_namespaces' do
        expect { subject }
          .to change { cluster.reload.cleanup_status_name }
          .from(:uninstalling_applications)
          .to(:removing_project_namespaces)
      end

      it 'schedules ClusterCleanupProjectNamespaceWorker' do
        expect(ClusterCleanupProjectNamespaceWorker).to receive(:perform_async).with(cluster.id)
        subject
      end

      it_behaves_like 'does not reschedule itself'

      it 'logs all events' do
        expect(logger).to receive(:info)
          .with(log_meta.merge(event: :schedule_remove_project_namespaces))

        subject
      end
    end

    context 'when cluster has uninstallable applications' do
      before do
        allow(described_class)
          .to receive(:perform_in)
          .with(20.seconds, cluster.id, 1)
      end

      shared_examples 'reschedules itself' do
        it 'reschedules itself' do
          expect(described_class)
            .to receive(:perform_in)
            .with(20.seconds, cluster.id, 1)

          subject
        end
      end

      context 'has applications with dependencies' do
        let!(:helm) { create(:clusters_applications_helm, :installed, cluster: cluster) }
        let!(:ingress) { create(:clusters_applications_ingress, :installed, cluster: cluster) }
        let!(:cert_manager) { create(:clusters_applications_cert_manager, :installed, cluster: cluster) }
        let!(:jupyter) { create(:clusters_applications_jupyter, :installed, cluster: cluster) }

        it_behaves_like 'reschedules itself'

        it 'only uninstalls apps that are not dependencies for other installed apps' do
          expect(Clusters::Applications::UninstallService)
            .not_to receive(:new).with(helm)

          expect(Clusters::Applications::UninstallService)
            .not_to receive(:new).with(ingress)

          expect(Clusters::Applications::UninstallService)
            .to receive(:new).with(cert_manager)
            .and_call_original

          expect(Clusters::Applications::UninstallService)
            .to receive(:new).with(jupyter)
            .and_call_original

          subject
        end

        it 'logs application uninstalls and next execution' do
          expect(logger).to receive(:info)
            .with(log_meta.merge(event: :uninstalling_app, application: kind_of(String))).exactly(2).times
          expect(logger).to receive(:info)
            .with(log_meta.merge(event: :scheduling_execution, next_execution: 1))

          subject
        end
      end

      context 'when applications are still uninstalling/scheduled' do
        let!(:helm) { create(:clusters_applications_helm, :installed, cluster: cluster) }
        let!(:ingress) { create(:clusters_applications_ingress, :scheduled, cluster: cluster) }
        let!(:runner) { create(:clusters_applications_runner, :uninstalling, cluster: cluster) }

        it_behaves_like 'reschedules itself'

        it 'does not call the uninstallation service' do
          expect(Clusters::Applications::UninstallService)
            .not_to receive(:new)

          subject
        end
      end
    end

    context 'when exceeded the execution limit' do
      subject { worker_instance.perform(cluster.id, worker_instance.send(:execution_limit)) }

      let(:worker_instance) { described_class.new }
      let(:logger) { worker_instance.send(:logger) }

      it_behaves_like 'does not reschedule itself'

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
