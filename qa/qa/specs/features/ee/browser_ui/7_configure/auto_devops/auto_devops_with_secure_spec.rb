# frozen_string_literal: true

require 'pathname'

module QA
  context 'Configure' do
    let(:project) do
      Resource::Project.fabricate_via_api! do |p|
        p.name = Runtime::Env.auto_devops_project_name || 'autodevops-project'
        p.description = 'Project with Auto DevOps'
        p.auto_devops_enabled = true
      end
    end

    before do
      disable_optional_jobs(project)
    end

    describe 'Auto DevOps support', :orchestrated, :kubernetes do
      context 'when rbac is enabled' do
        let(:cluster) { Service::KubernetesCluster.new.create! }

        after do
          cluster&.remove!
        end

        it 'runs auto devops' do
          Flow::Login.sign_in

          # Connect K8s cluster
          Resource::KubernetesCluster.fabricate! do |k8s_cluster|
            k8s_cluster.project = project
            k8s_cluster.cluster = cluster
            k8s_cluster.install_helm_tiller = true
            k8s_cluster.install_ingress = true
            k8s_cluster.install_prometheus = true
            k8s_cluster.install_runner = true
          end

          # Create Auto DevOps compatible repo
          Resource::Repository::ProjectPush.fabricate! do |push|
            push.project = project
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
            pipeline.click_job('dependency_scanning')
          end
          Page::Project::Job::Show.perform do |job|
            expect(job).to be_successful(timeout: 600)

            job.click_element(:pipeline_path)
          end
        end
      end
    end

    private

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
