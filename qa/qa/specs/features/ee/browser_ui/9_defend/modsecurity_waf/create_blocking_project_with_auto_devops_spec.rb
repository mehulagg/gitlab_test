# frozen_string_literal: true

require 'pathname'

module QA
  context 'Defend' do
    describe 'Auto DevOps support', :orchestrated, :kubernetes do
      context 'when rbac is enabled' do
        before(:all) do
          @cluster = Service::KubernetesCluster.new.create!
        end

        after(:all) do
          @cluster&.remove!
        end

        it 'runs auto devops to default to detectiononly mode' do
          Flow::Login.sign_in

          @project = Resource::Project.fabricate! do |p|
            p.name = Runtime::Env.auto_devops_project_name || 'project-with-autodevops'
            p.description = 'Project with Auto DevOps'
            p.auto_devops_enabled = true
          end

          disable_optional_jobs(@project)

          # Set an application secret CI variable (prefixed with K8S_SECRET_)
          Resource::CiVariable.fabricate! do |resource|
            resource.project = @project
            resource.key = 'K8S_SECRET_OPTIONAL_MESSAGE'
            resource.value = 'you_can_see_this_variable'
            resource.masked = false
          end

          # Connect K8s cluster
          Resource::KubernetesCluster.fabricate! do |cluster|
            cluster.project = @project
            cluster.cluster = @cluster
            cluster.install_helm_tiller = true
            cluster.install_ingress = true
            cluster.install_prometheus = true
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
            pipeline.click_job('test')
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

          Page::Project::Menu.perform(&:go_to_operations_environments)
          Page::Project::Operations::Environments::Index.perform do |index|
            index.click_environment_link('production')
          end
          Page::Project::Operations::Environments::Show.perform do |show|
            show.view_deployment do
              expect(page).to have_content('Hello World!')

              open("?<script>alert('hello')</script>")

              expect(page).to have_content('Forbidden')
            end
          end
        end

        it 'runs auto devops to deploy blocking mode' do
          Flow::Login.sign_in

          @project = Resource::Project.fabricate! do |p|
            p.name = Runtime::Env.auto_devops_project_name || 'project-with-autodevops'
            p.description = 'Project with Auto DevOps'
            p.auto_devops_enabled = true
          end

          disable_optional_jobs(@project)
          enable_blocking_mode(@project)

          # Set an application secret CI variable (prefixed with K8S_SECRET_)
          Resource::CiVariable.fabricate! do |resource|
            resource.project = @project
            resource.key = 'K8S_SECRET_OPTIONAL_MESSAGE'
            resource.value = 'you_can_see_this_variable'
            resource.masked = false
          end

          # Connect K8s cluster
          Resource::KubernetesCluster.fabricate! do |cluster|
            cluster.project = @project
            cluster.cluster = @cluster
            cluster.install_helm_tiller = true
            cluster.install_ingress = true
            cluster.install_prometheus = true
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
            pipeline.click_job('test')
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

          Page::Project::Menu.perform(&:go_to_operations_environments)
          Page::Project::Operations::Environments::Index.perform do |index|
            index.click_environment_link('production')
          end
          Page::Project::Operations::Environments::Show.perform do |show|
            show.view_deployment do
              expect(page).to have_content('Hello World!')

              open("?<script>alert('hello')</script>")

              expect(page).to have_content('Forbidden')
            end
          end
        end
      end
    end

    def enable_blocking_mode(project)
      # Blocking mode is enabled via ENV variable by enabling
      # modsecurity-snippet in Auto-Deploy helm chart
      Resource::CiVariable.fabricate_via_api! do |resource|
        resource.project = project
        resource.key = 'AUTO_DEVOPS_MODSEC_RULE_ENGINE'
        resource.value = 'On'
        resource.masked = false
      end
    end

    def disable_optional_jobs(project)
      %w[
        CODE_QUALITY_DISABLED LICENSE_MANAGEMENT_DISABLED
        SAST_DISABLED DAST_DISABLED CONTAINER_SCANNING_DISABLED
      ].each do |key|
        Resource::CiVariable.fabricate_via_api! do |resource|
          resource.project = project
          resource.key = key
          resource.value = '1'
          resource.masked = false
        end
      end
    end
  end
end
