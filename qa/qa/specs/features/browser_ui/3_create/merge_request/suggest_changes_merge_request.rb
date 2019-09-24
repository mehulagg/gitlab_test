# frozen_string_literal: true

module QA
  context 'Create', :requires_admin do
    before(:context) do
      # 1. As a "root" user, create a new "developer-user" user.
      @developer_user = Resource::User.fabricate_via_api! do |user|
        user.name = 'John'
        user.password = '1234Test@'
      end

      # 2. As a "root" user, create a project.
      @project = Resource::Project.fabricate_via_api! do |p|
        p.name = 'project-to-suggestion'
        p.initialize_with_readme = true
      end
    end

    describe 'suggestion for merge request as a root user' do
      it 'should see suggested changes when developer user apply the suggestion' do
        # 3. Add the "developer-user" user to the project.
        @project.visit!
        Page::Project::Menu.perform(&:go_to_members_settings)
        Page::Project::Settings::Members.perform do |members|
          members.add_member(@developer_user.username, 'Developer')
        end

        # 4. As the "developer-user" user, commit a file to the project using SSH in a new branch.
        push_new_file

        # 5. As the "developer-user" user, create a merge request (MR) and assign it to the "root" user for review.
        Page::Main::Menu.perform(&:sign_out)
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform { |login| login.sign_in_using_credentials(user: @developer_user) }

        merge_request = Resource::MergeRequest.fabricate_via_browser_ui! do |mr|
          mr.project = @project
          mr.assignee = 'root'
          mr.source_branch = 'test/suggest_changes_merge_request'
          mr.title = "Developer User creates an MR"
        end

        # 6. As the "root" user, suggest a change using the "Insert suggestion" button.
        Page::Main::Menu.perform(&:sign_out)
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform { |login| login.sign_in_using_credentials }

        @project.visit!
        Page::Project::Menu.perform(&:click_merge_requests)
        Page::MergeRequest::Show.perform do |mr|
          mr.go_to_mr(merge_request.title)
          mr.insert_suggestion("```suggestion:-0+0\nputs \"Review is OK!\"\n```")
        end

        # 7. As the "developer-user" user, apply the change.
        Page::Main::Menu.perform(&:sign_out)
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform { |login| login.sign_in_using_credentials(user: @developer_user) }
        @project.visit!
        Page::Project::Menu.perform(&:click_merge_requests)
        Page::MergeRequest::Show.perform do |mr|
          mr.go_to_mr(merge_request.title)
          mr.apply_suggestion
        end

        # 8. As the "root" user, merge the MR.
        Page::Main::Menu.perform(&:sign_out)
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform { |login| login.sign_in_using_credentials }

        @project.visit!
        Page::Project::Menu.perform(&:click_merge_requests)
        Page::MergeRequest::Show.perform do |mr|
          mr.go_to_mr(merge_request.title)
          mr.merge!
        end

        # 9. As the "root" user, ensure that the repository now has the file with the suggested changes.
        @project.visit!
        expect(Page::Project::Show.perform do |p|
          p.file_content('suggestion.rb')
        end).to have_content('Review is OK!')
      end
    end

    def push_new_file(wait_for_push: true)
      commit_message = 'testing suggestion'
      output = Resource::Repository::Push.fabricate! do |p|
        p.repository_http_uri = @project.repository_http_location.uri
        p.file_name = 'suggestion.rb'
        p.file_content = 'puts "Ready to review"'
        p.commit_message = commit_message
        p.branch_name = 'test/suggest_changes_merge_request'
        p.user = @developer_user
      end
      @project.wait_for_push commit_message

      output
    end
  end
end
