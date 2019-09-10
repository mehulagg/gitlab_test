# frozen_string_literal: true

module QA
  context 'Configure' do
    def login
      Runtime::Browser.visit(:gitlab, Page::Main::Login)
      Page::Main::Login.perform(&:sign_in_using_credentials)
    end

    def disable_optional_jobs(project)
      %w[CODE_QUALITY_DISABLED LICENSE_MANAGEMENT_DISABLED SAST_DISABLED
        DAST_DISABLED CONTAINER_SCANNING_DISABLED DEPENDENCY_SCANNING_DISABLED].each do |key|
        Resource::CiVariable.fabricate_via_api! do |resource|
          resource.project = project
          resource.key = key
          resource.value = '1'
          resource.masked = false
        end
      end
    end

    context 'AutoDevOps' do
      describe 'Kubernetes Pod Logs' do
        before do
          @cluster = Service::KubernetesCluster.new.create!
        end

        after do
          @cluster&.remove!
        end

        it 'can view kubernetes pod logs' do
          login

          @project = Resource::Project.fabricate! do |p|
            p.name = "project-with-k8s-pod-logs-#{SecureRandom.hex(5)}"
            p.description = 'Project with Kubernetes pod logs'
          end

          # Ensure AutoDevOps is enabled
          Page::Project::Menu.perform(&:go_to_ci_cd_settings)
          Page::Project::Settings::CICD.perform(&:expand_auto_devops)
          Page::Project::Settings::AutoDevops.perform(&:enable_autodevops)

          disable_optional_jobs(@project)

          # Connect K8s cluster
          Resource::KubernetesCluster.fabricate! do |cluster|
            cluster.project = @project
            cluster.cluster = @cluster
            cluster.install_helm_tiller = true
            cluster.install_ingress = true
            cluster.install_prometheus = true
            cluster.install_runner = true
          end

          Resource::Repository::ProjectPush.fabricate! do |push|
            push.project = @project
            push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../../fixtures/auto_devops_rack')
            push.commit_message = 'Create Auto DevOps compatible rack application'
          end

          Page::Project::Menu.perform(&:click_ci_cd_pipelines)
          Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)

          Page::Project::Pipeline::Show.perform do |show|
            show.click_job('production')
          end

          Page::Project::Job::Show.perform do |job|
            expect(job).to be_successful(timeout: 2400)
          end

          Page::Project::Menu.perform(&:go_to_operations_environments)
        end
      end
    end
  end
end
