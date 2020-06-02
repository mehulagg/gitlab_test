# frozen_string_literal: true

module QA
  context 'Monitor' do
    describe 'with Prometheus Gitlab-managed cluster', :orchestrated, :kubernetes, :requires_admin do
      before :all do
        Flow::Login.sign_in_as_admin
        @project, @cluster = deploy_project_with_prometheus
      end

      before do
        Flow::Login.sign_in_unless_signed_in
        @project.visit!
      end

      after :all do
        @cluster&.remove!
      end

      it 'configures custom metrics' do
        verify_add_custom_metric
        verify_edit_custom_metric
        verify_delete_custom_metric
      end

      it 'duplicates to create dashboard to custom' do
        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          dashboard.duplicate_dashboard

          expect(dashboard).to have_metrics
          expect(dashboard).to have_edit_dashboard_enabled
        end
      end

      it 'verifies data on filtered deployed environment' do
        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          dashboard.filter_environment

          expect(dashboard).to have_metrics
        end
      end

      it 'filters using the quick range' do
        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          dashboard.show_last('30 minutes')
          expect(dashboard).to have_metrics

          dashboard.show_last('3 hours')
          expect(dashboard).to have_metrics

          dashboard.show_last('1 day')
          expect(dashboard).to have_metrics
        end

        it 'uses templating variables' do
          # 1. upload variables.yml
          upload_variables_yml_file
          # 2. go to the metrics and select a combo of variables and filter by time-range
          Page::Project::Menu.perform(&:go_to_operations_metrics)

          Page::Project::Operations::Metrics::Show.perform do |dashboard|
            dashboard.show_last('30 minutes')
            # select variables.yml
            # select pod
            # 3. assert that metrics are loaded
            expect(dashboard).to have_metrics
          end

          # 4. copy URL open in new page (or paste in issue)

          # 5. assert variable values are persistent
          # 6. delete templating variables from repo
          delete_file_from_repository
          # 7. go to the metrics and assert templating variables are removed
          Page::Project::Menu.perform(&:go_to_operations_metrics)

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
                               .join('../../../../fixtures/auto_devops_rack')
          push.commit_message = 'Use Auto Devops rack for monitoring'
        end

        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success_or_retry)

        [project, cluster]
      end

      def verify_add_custom_metric
        Page::Project::Menu.perform(&:go_to_integrations_settings)
        Page::Project::Settings::Integrations.perform(&:click_on_prometheus_integration)

        Page::Project::Settings::Services::Prometheus.perform do |metrics_panel|
          metrics_panel.click_on_new_metric
          metrics_panel.add_custom_metric
        end

        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          expect(dashboard).to have_custom_metric('HTTP Requests Total')
        end
      end

      def verify_edit_custom_metric
        Page::Project::Menu.perform(&:go_to_integrations_settings)
        Page::Project::Settings::Integrations.perform(&:click_on_prometheus_integration)
        Page::Project::Settings::Services::Prometheus.perform do |metrics_panel|
          metrics_panel.click_on_custom_metric('Business / HTTP Requests Total (req/sec)')
          metrics_panel.edit_custom_metric
        end

        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          expect(dashboard).to have_custom_metric('Throughput')
        end
      end

      def verify_delete_custom_metric
        Page::Project::Menu.perform(&:go_to_integrations_settings)
        Page::Project::Settings::Integrations.perform(&:click_on_prometheus_integration)

        Page::Project::Settings::Services::Prometheus.perform do |metrics_panel|
          metrics_panel.click_on_custom_metric('Business / Throughput (req/sec)')
          metrics_panel.delete_custom_metric
        end

        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          expect(dashboard).not_to have_custom_metric('Throughput')
        end
      end

      def upload_variables_yml_file
        variables_yml_file = <<~YAML
            dashboard: 'Pod metrics'
            priority: 10
            templating:
              variables:
                pod_name: 'event-exporter-v0.2.4-5f7d5d7dd4-gtk8b'
                pod_name2: 'fluentd-gcp-scaler-6965bb45c9-ghl27'
            panel_groups:
            - group: CPU metrics
              panels:
              - title: "CPU usage"
                type: "line-chart"
                y_label: "Cores per pod"
                metrics:
                - id: pod_cpu_usage_seconds_total
                  query_range: 'rate(container_cpu_usage_seconds_total{pod_name="{{pod_name}}"}[5m])'
                  unit: "cores"
                  label: pod_name
              - title: "Memory usage working set"
                type: "line-chart"
                y_label: "Working set memory (MiB)"
                metrics:
                - id: pod_memory_working_set1
                  query_range: 'container_memory_working_set_bytes{pod_name="{{pod_name2}}"}/1024/1024'
                  unit: "MiB"
                   label: pod_name
        YAML

        push_file_to_repository(variables_yml_file)
      end

      def push_file_to_repository(file)
        @project.visit!

        Page::Project::Show.perform(&:create_new_file!)

        Page::File::Form.perform do |form|
          form.add_name('.gitlab/dashboards/variables.yml')
          form.add_content(file)
          form.commit_changes
        end
      end

      def delete_file_from_repository
        Page::File::Show.act do
          click_delete
          click_delete_file
        end
      end
    end
  end
end
