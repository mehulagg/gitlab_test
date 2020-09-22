# frozen_string_literal: true

module QA
  RSpec.describe 'Plan' do
    describe 'Assign Iterations' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.group = @iteration.group
          project.name = "project-to-test-iterations-#{SecureRandom.hex(8)}"
        end
      end

      let(:issue) do
        Resource::Issue.fabricate_via_api! do |issue|
          issue.project = project
          issue.title = "issue-to-test-iterations-#{SecureRandom.hex(8)}"
        end
      end

      before do
        Flow::Login.sign_in
      end

      it 'assigns a group iteration to an existing issue', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/958' do
        @iteration = EE::Resource::GroupIteration.fabricate_via_browser_ui!

        issue.visit!

        Page::Project::Issue::Show.perform do |issue|
          issue.assign_iteration(@iteration)

          expect(issue).to have_iteration(@iteration.title)
        end
      end
    end
  end
end
