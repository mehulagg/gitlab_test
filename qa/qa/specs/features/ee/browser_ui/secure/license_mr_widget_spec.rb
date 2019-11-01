# frozen_string_literal: true

require 'pathname'

module QA
  context 'Secure', :docker do
    describe 'License merge request widget' do
      let(:approved_license_name) { "MIT" }
      let(:blacklisted_license_name) { "Zlib" }

      after do
        Service::DockerRun::GitlabRunner.new(@executor).remove!
      end

      before do
        @executor = "qa-runner-#{Time.now.to_i}"

        # Handle WIP Job Logs flag - https://gitlab.com/gitlab-org/gitlab/issues/31162
        @job_log_json_flag_enabled = Runtime::Feature.enabled?('job_log_json')
        Runtime::Feature.disable('job_log_json') if @job_log_json_flag_enabled

        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        @project = Resource::Project.fabricate_via_api! do |project|
          project.name = Runtime::Env.auto_devops_project_name || 'license-widget-project'
          project.description = 'License widget test'
        end

        Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = @executor
          runner.tags = %w[qa test]
        end

        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = @project
          project_push.directory = Pathname
            .new(__dir__)
            .join('../../../../../ee/fixtures/license_files')
          project_push.commit_message = 'Create license file'
        end

        @project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
        wait_for_job "license_management"

        @merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = @project
          mr.source_branch = 'secure-mr'
          mr.target_branch = 'master'
          mr.source = @source
          mr.target = 'master'
          mr.file_name = 'gl-license-management-report.json'
          mr.file_content = <<~FILE_UPDATE
            {
              "licenses": [
                {
                  "count": 1,
                  "name": "WTFPL"
                },
                {
                  "count": 1,
                  "name": "MIT"
                },
                {
                  "count": 1,
                  "name": "Zlib"
                }
              ]
            }
            FILE_UPDATE
          mr.target_new_branch = false
        end

        @project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
        wait_for_job "license_management"
      end

      it 'manage licenses from the merge request' do
        @merge_request.visit!

        Page::MergeRequest::Show.perform do |show|
          show.approve_license_with_mr(approved_license_name)
          show.blacklist_license_with_mr(blacklisted_license_name)

          expect(show).to have_approved_license approved_license_name
          expect(show).to have_blacklisted_license blacklisted_license_name
        end
      end
    end

    def wait_for_job(job_name)
      Page::Project::Pipeline::Show.perform do |pipeline|
        pipeline.click_job(job_name)
      end
      Page::Project::Job::Show.perform do |job|
        expect(job).to be_successful(timeout: 600)
      end
    end
  end
end
