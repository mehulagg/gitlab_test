# frozen_string_literal: true

module QA
  context 'Monitor' do
    describe 'Features', :orchestrated, :kubernetes do
      before(:all) do
        @cluster = Service::KubernetesCluster.new.create!

        Flow::Login.while_signed_in do
          @project = create_project
          create_kubernetes_cluster(@project, @cluster)
        end
      end

      after(:all) do
        @cluster&.remove!
      end

      before do
        Flow::Login.sign_in
        @project.visit!
      end

      it 'installs Kubernetes and Prometheus' do
        Page::Project::Menu.perform(&:go_to_operations_kubernetes)

        click_on @cluster.cluster_name

        verify_cluster_health_graphs
      end

      context 'with a deployment' do
        before do
          push_repository(@project)
          wait_for_deployment
        end

        it 'allows configuration of alerts' do
          Page::Project::Operations::Metrics.perform do |metrics|
            verify_metrics(metrics)
            verify_add_alert(metrics)
            verify_edit_alert(metrics)
            verify_persist_alert(metrics)
            verify_delete_alert(metrics)
          end
        end
      end

      private

      def create_project
        Resource::Project.fabricate_via_api! do |p|
          p.name = 'alerts'
          p.description = 'Project with alerting configured'
        end
      end

      def create_kubernetes_cluster(project, cluster)
        Resource::KubernetesCluster.fabricate_via_browser_ui! do |c|
          c.project = project
          c.cluster = cluster
          c.install_helm_tiller = true
          c.install_prometheus = true
          c.install_runner = true
        end
      end

      def push_repository(project)
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.directory = Pathname
            .new(__dir__)
            .join('../../../../../../fixtures/monitored_auto_devops')
          push.commit_message = 'Create Auto DevOps compatible gitlab-ci.yml'
        end
      end

      def wait_for_deployment
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)
        Page::Project::Menu.perform(&:go_to_operations_metrics)
      end

      def verify_cluster_health_graphs
        Page::Project::Operations::Kubernetes::Show.perform do |cluster|
          cluster.refresh
          expect(cluster).to have_cluster_health_title

          cluster.wait_for_cluster_health
        end
      end

      def verify_metrics(metrics)
        metrics.wait_for_metrics

        expect(metrics).to have_metrics
        expect(metrics).not_to have_alert
      end

      def verify_add_alert(metrics)
        metrics.add_alert

        expect(metrics).to have_alert
      end

      def verify_edit_alert(metrics)
        metrics.edit_alert

        expect(metrics).to have_alert('<')
      end

      def verify_persist_alert(metrics)
        metrics.refresh
        metrics.wait_for_metrics
        metrics.wait_for_alert('<')

        expect(metrics).to have_alert('<')
      end

      def verify_delete_alert(metrics)
        metrics.delete_alert
        sleep 1

        expect(metrics).not_to have_alert('<')
      end
    end
  end
end
