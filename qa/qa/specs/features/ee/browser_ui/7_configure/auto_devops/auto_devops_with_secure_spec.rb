# frozen_string_literal: true

require 'pathname'

module QA
  context 'Configure' do
    def disable_optional_jobs(project)
      # Disable code_quality check in Auto DevOps pipeline as it takes
      # too long and times out the test
      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = project
        resource.key = 'CODE_QUALITY_DISABLED'
        resource.value = '1'
        resource.masked = false
      end

      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = project
        resource.key = 'LICENSE_MANAGEMENT_DISABLED'
        resource.value = '1'
        resource.masked = false
      end

      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = project
        resource.key = 'SAST_DISABLED'
        resource.value = '1'
        resource.masked = false
      end

      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = project
        resource.key = 'CONTAINER_SCANNING_DISABLED'
        resource.value = '1'
        resource.masked = false
      end

      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = project
        resource.key = 'DAST_DISABLED'
        resource.value = '1'
        resource.masked = false
      end
    end

    describe 'Auto DevOps support', :orchestrated, :kubernetes do
      context 'when dependency scanning is enabled' do
        before(:all) do
          @cluster = Service::KubernetesCluster.new.create!
        end

        after(:all) do
          @cluster&.remove!
        end

        it 'runs auto devops with a dependency scanning job' do
          @executor = "qa-runner-#{Time.now.to_i}"

          Flow::Login.sign_in

          @project = Resource::Project.fabricate! do |p|
            p.name = Runtime::Env.auto_devops_project_name || 'project-with-autodevops'
            p.description = 'Project with Auto DevOps'
            p.auto_devops_enabled = true
          end

          disable_optional_jobs(@project)

          # Connect K8s cluster
          Resource::KubernetesCluster.fabricate! do |cluster|
            cluster.project = @project
            cluster.cluster = @cluster
            cluster.install_helm_tiller = true
            cluster.install_runner = true
          end

          # Create Auto DevOps compatible repo
          Resource::Repository::ProjectPush.fabricate! do |push|
            push.project = @project
            push.directory = Pathname
              .new(__dir__)
              .join('../../../../../fixtures/auto_devops_rack')
            push.commit_message = 'Create Auto DevOps compatible rack application'
          end

          @project.visit!
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
            pipeline.click_job('dependency_scanning')
          end
          Page::Project::Job::Show.perform do |job|
            expect(job).to be_successful(timeout: 600)

            job.click_element(:pipeline_path)
          end
        end
      end
    end
  end
end
