# frozen_string_literal: true

module QA
  context 'Secure', :docker, :runner do
    describe 'Security Dashboard in a Project' do
      let(:vuln_name) { "Regular Expression Denial of Service in debug" }
      let(:remediable_vuln_name) { "Authentication bypass via incorrect DOM traversal and canonicalization in saml2-js" }

      before(:all) do
        @executor = "qa-runner-#{Time.now.to_i}"

        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |p|
          p.name = Runtime::Env.auto_devops_project_name || 'project-with-secure'
          p.description = 'Project with Secure'
          p.auto_devops_enabled = false
          p.initialize_with_readme = true
        end

        @runner = Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = @executor
          runner.tags = %w[qa test]
        end

        # Push fixture to generate Secure reports
        @source = Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = @project
          push.directory = Pathname
            .new(__dir__)
            .join('../../../../../ee/fixtures/secure_premade_reports')
          push.commit_message = 'Create Secure compatible application to serve premade reports'
          push.branch_name = 'secure-mr'
        end

        @merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = @project
          mr.source_branch = 'secure-mr'
          mr.target_branch = 'master'
          mr.source = @source
          mr.target = 'master'
          mr.target_new_branch = false
        end

        @merge_request.visit!
        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.merge!
        end
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)

        @project_security_dashboard = EE::Resource::SecurityDashboard::ProjectSecurityDashboard.new(project: @project)
      end

      after(:all) do
        @runner.remove_via_api!

        Runtime::Feature.enable('job_log_json') if @job_log_json_flag_enabled
      end

      it 'shows vulnerability details' do
        @project_security_dashboard.visit!

        EE::Page::Project::Secure::SecurityDashboard.perform do |security_dashboard|
          expect(security_dashboard).to have_vulnerability(vuln_name)
        end
      end
    end
  end
end
