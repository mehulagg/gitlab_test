# frozen_string_literal: true

module QA
  context 'Monitor' do
    describe 'with Prometheus Gitlab-managed cluster', :orchestrated, :kubernetes, :requires_admin do
      before :all do
        Flow::Login.sign_in
        @project, @cluster = deploy_project_with_prometheus
      end

      after :all do
        @cluster&.remove!
      end

      before do
        Flow::Login.sign_in_unless_signed_in
        @project.visit!
      end

      it 'allows configuration of alerts' do
        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |metrics|
          verify_metrics(metrics)
          verify_add_alert(metrics)
          verify_edit_alert(metrics)
          verify_persist_alert(metrics)
          verify_delete_alert(metrics)
        end
      end

      it 'observes cluster health graph' do
        Page::Project::Menu.perform(&:go_to_operations_kubernetes)

        Page::Project::Operations::Kubernetes::Index.perform do |cluster|
          cluster.click_on_cluster(@cluster)
        end

        Page::Project::Operations::Kubernetes::Show.perform do |cluster|
          cluster.open_health

          cluster.wait_for_cluster_health
        end
      end

      it 'creates and sets an incident template' do
        create_incident_template

        Page::Project::Menu.perform(&:go_to_operations_settings)

        Page::Project::Settings::Operations.perform do |settings|
          settings.expand_incidents do |incident_settings|
            incident_settings.enable_issues_for_incidents
            incident_settings.select_issue_template('incident')
            incident_settings.save_incident_settings
          end
          settings.expand_incidents do |incident_settings|
            expect(incident_settings).to have_template('incident')
          end
        end
      end

      private

      def deploy_project_with_prometheus
        project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'cluster-with-prometheus'
          project.auto_devops_enabled = true
        end

        cluster = Service::KubernetesCluster.new(provider_class: Service::ClusterProvider::K3s).create!

        Resource::KubernetesCluster::ProjectCluster.fabricate! do |cluster_settings|
          cluster_settings.project = project
          cluster_settings.cluster = cluster
          cluster_settings.install_helm_tiller = true
          cluster_settings.install_ingress = true
          cluster_settings.install_runner = true
          cluster_settings.install_prometheus = true
        end

        %w[
        CODE_QUALITY_DISABLED LICENSE_MANAGEMENT_DISABLED
        SAST_DISABLED DAST_DISABLED DEPENDENCY_SCANNING_DISABLED
        CONTAINER_SCANNING_DISABLED TEST_DISABLED PERFORMANCE_DISABLED
      ].each do |key|
          Resource::CiVariable.fabricate_via_api! do |resource|
            resource.project = project
            resource.key = key
            resource.value = '1'
            resource.masked = false
          end
        end

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../../fixtures/auto_devops_rack')
          push.commit_message = 'Use Auto Devops rack for monitoring'
        end

        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success_or_retry)

        [project, cluster]
      end

      def verify_metrics(metrics)
        metrics.wait_for_metrics

        expect(metrics).to have_metrics
        expect(metrics).not_to have_alert
      end

      def verify_add_alert(metrics)
        metrics.write_first_alert('>', 0)

        expect(metrics).to have_alert
      end

      def verify_edit_alert(metrics)
        metrics.write_first_alert('<', 0)

        expect(metrics).to have_alert('<')
      end

      def verify_persist_alert(metrics)
        metrics.refresh
        metrics.wait_for_metrics
        metrics.wait_for_alert('<')

        expect(metrics).to have_alert('<')
      end

      def verify_delete_alert(metrics)
        metrics.delete_first_alert

        expect(metrics).not_to have_alert('<')
      end

      def create_incident_template
        Page::Project::Menu.perform(&:go_to_operations_metrics)

        @chart_link = Page::Project::Operations::Metrics::Show.perform do |metric|
          metric.wait_for_metrics
          metric.copy_link_to_first_chart
        end

        incident_template = "Incident Metric: #{@chart_link}"
        push_template_to_repository(incident_template)
      end

      def push_template_to_repository(template)
        @project.visit!

        Page::Project::Show.perform(&:create_new_file!)

        Page::File::Form.perform do |form|
          form.add_name('.gitlab/issue_templates/incident.md')
          form.add_content(template)
          form.add_commit_message('Add Incident template')
          form.commit_changes
        end
      end
    end
  end
end
