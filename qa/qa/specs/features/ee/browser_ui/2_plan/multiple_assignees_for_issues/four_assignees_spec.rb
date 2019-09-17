# frozen_string_literal: true

module QA
  context 'Plan' do
    describe 'Multiple assignees per issue' do
      before do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        @user_1 = Resource::User.fabricate_via_api!
        @user_2 = Resource::User.fabricate_via_api!
        @user_3 = Resource::User.fabricate_via_api!
        @user_4 = Resource::User.fabricate_via_api!

        project = Resource::Project.fabricate_via_api! do |resource|
          resource.name = 'project-to-issue-with-multiple-assignees'
        end
        project.visit!

        Page::Project::Show.perform(&:go_to_members_settings)
        Page::Project::Settings::Members.perform do |members|
          members.add_member(@user_1.username)
          members.add_member(@user_2.username)
          members.add_member(@user_3.username)
          members.add_member(@user_4.username)
        end

        Resource::Issue.fabricate_via_api! do |issue|
          issue.title = issue.title = 'issue-to-test-multiple-assignees'
          issue.project = project
          issue.assignee_ids = [
            @user_1.id,
            @user_2.id,
            @user_3.id,
            @user_4.id
          ]
        end
      end

      it 'shows four assignees in the issues list' do
        Page::Project::Menu.perform(&:click_issues)

        Page::Project::Issue::Index.perform do |index|
          expect(index.author_link_count).to be 4
        end
      end
    end
  end
end
