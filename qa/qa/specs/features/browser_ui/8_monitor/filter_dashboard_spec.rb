# frozen_string_literal: true
require 'pathname'

module QA
  context 'Monitor' do
    describe 'with Prometheus Gitlab-managed cluster', :orchestrated, :kubernetes, :requires_admin do
      let(:cluster) { Service::KubernetesCluster.new(provider_class: Service::ClusterProvider::K3s).create! }
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-k3s'
          project.auto_devops_enabled = true
        end
      end

      before do
        disable_optional_jobs(project)
        Flow::Login.sign_in_as_admin
        deploy_project_to_monitor(cluster, project)
      end

      after do
        cluster.remove!
      end

      it 'verifies data on filtered deployed environment' do
        Page::Project::Menu.perform(&:go_to_operations_metrics)

        Page::Project::Operations::Metrics::Show.perform do |dashboard|
          dashboard.filter_environment

          expect(dashboard).to have_metrics
        end
      end

      private

      def disable_optional_jobs(project)
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
      end

      def deploy_project_to_monitor(cluster, project)
        Resource::KubernetesCluster::ProjectCluster.fabricate! do |cluster_settings|
          cluster_settings.project = project
          cluster_settings.cluster = cluster
          cluster_settings.install_helm_tiller = true
          cluster_settings.install_ingress = true
          cluster_settings.install_runner = true
          cluster_settings.install_prometheus = true
        end

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../fixtures/auto_devops_rack')
          push.commit_message = 'Use Auto Devops rack for monitoring'
        end

        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('build')
        end
        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 600)

          job.click_element(:pipeline_path)
        end

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('production')
        end
        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 1200)

          job.click_element(:pipeline_path)
        end
      end
    end
  end
end

