# frozen_string_literal: true

module QA
  RSpec.shared_context "cluster with Prometheus installed" do
    before :all do
      @cluster = Service::KubernetesCluster.new(provider_class: Service::ClusterProvider::K3s).create!
      @project = Resource::Project.fabricate_via_api! do |project|
        project.name = 'monitoring-project'
        project.auto_devops_enabled = false
      end

      deploy_project_with_prometheus
    end

    def deploy_project_with_prometheus
      %w[
          CODE_QUALITY_DISABLED TEST_DISABLED LICENSE_MANAGEMENT_DISABLED
          SAST_DISABLED DAST_DISABLED DEPENDENCY_SCANNING_DISABLED
          CONTAINER_SCANNING_DISABLED PERFORMANCE_DISABLED SECRET_DETECTION_DISABLED
        ].each do |key|
        Resource::CiVariable.fabricate_via_api! do |resource|
          resource.project = @project
          resource.key = key
          resource.value = '1'
          resource.masked = false
        end
      end

      Flow::Login.sign_in

      cluster_props = Resource::KubernetesCluster::ProjectCluster.fabricate! do |cluster_settings|
        cluster_settings.project = @project
        cluster_settings.cluster = @cluster
        cluster_settings.install_ingress = true
        cluster_settings.install_runner = true
        cluster_settings.install_prometheus = true
      end

      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = @project
        resource.key = 'AUTO_DEVOPS_DOMAIN'
        resource.value = cluster_props.ingress_ip
        resource.masked = false
      end

      ci_file = Pathname
                    .new(__dir__)
                    .join('../../../../fixtures/.gitlab-ci.yml')

      Resource::Repository::ProjectPush.fabricate! do |push|
        push.project = @project
        push.file_name = '.gitlab-ci.yml'
        push.file_content = File.read(ci_file)
        push.commit_message = 'Add ci-yml file'
      end

      Resource::Pipeline.fabricate_via_api! do |pipeline|
        pipeline.project = @project
      end.visit!

      Page::Project::Pipeline::Show.perform do |pipeline|
        pipeline.click_job('production')
      end
      Page::Project::Job::Show.perform do |job|
        expect(job).to be_successful(timeout: 1200)

        job.click_element(:pipeline_path)
      end
    end

    after :all do
      @cluster&.remove!
    end
  end
end
