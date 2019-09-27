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

      # 3. Add the "developer-user" user to the project.
      Resource::ProjectMember.fabricate_via_api! do |member|
        member.user = @developer_user
        member.project = @project
        member.access_level = member.level[:developer]
      end

      # 4. As the "developer-user" user, commit a file to the project using SSH in a new branch.
      go_to_project @developer_user
      ssh_key = Resource::SSHKey.fabricate! do |resource|
        resource.title = "key for ssh tests #{Time.now.to_f}"
      end

      push_new_file(ssh_key)

      # 5. As the "developer-user" user, create a merge request (MR) and assign it to the "root" user for review.
      merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
        mr.project = @project
        mr.target_branch = 'master'
        mr.source_branch = 'test/suggest_changes_merge_request'
        mr.title = 'Developer User creates an MR'
        mr.no_preparation = true
      end

      # 6. As the "root" user, suggest a change using the "Insert suggestion" button.
      go_to_project
      Page::Project::Menu.perform(&:click_merge_requests)
      Page::MergeRequest::Show.perform do |mr|
        mr.click_mr(merge_request.title)
        mr.insert_suggestion("```suggestion:-0+0\nputs \"Review is OK!\"\n```")
      end

      # 7. As the "developer-user" user, apply the change.
      go_to_project @developer_user
      Page::Project::Menu.perform(&:click_merge_requests)
      Page::MergeRequest::Show.perform do |mr|
        mr.click_mr(merge_request.title)
        mr.apply_suggestion
      end

      # 8. As the "root" user, merge the MR.
      go_to_project
      Page::Project::Menu.perform(&:click_merge_requests)
      Page::MergeRequest::Show.perform do |mr|
        mr.click_mr(merge_request.title)
        mr.merge!
      end
    end

    describe 'suggestion for merge request as a root user' do
      it 'should see suggested changes when developer user apply the suggestion' do
        # 9. As the "root" user, ensure that the repository now has the file with the suggested changes.
        @project.visit!
        expect(Page::Project::Show.perform do |p|
          p.file_content('suggestion.rb')
        end).to have_content('Review is OK!')
      end
    end

    def go_to_project(user = nil)
      Page::Main::Menu.perform(&:sign_out)
      Runtime::Browser.visit(:gitlab, Page::Main::Login)
      Page::Main::Login.perform {|login| login.sign_in_using_credentials(user: user)}

      @project.visit!
    end

    def push_new_file(ssh_key)
      Resource::Repository::Push.fabricate! do |p|
        p.repository_ssh_uri = @project.repository_ssh_location.uri
        p.ssh_key = ssh_key
        p.file_name = 'suggestion.rb'
        p.file_content = 'puts "Ready to review"'
        p.commit_message = 'testing suggestion'
        p.branch_name = 'test/suggest_changes_merge_request'
      end
    end
  end
end
