require 'securerandom'

module QA
    context 'Manage' do #? Or Plan ?
      describe 'Sharing groups with groups with different permissions' do
        before(:all) do
          #create users(ParentUserA, GroupUserA, ProjectUserA, ParentUserB, GroupUserB, ProjectUserB)
          #create groups(ParentGroupA, GroupProjectA, ProjectA, ParentGroupB, GroupProjectB, ProjectB)
          #@sandbox_group = Resource::Sandbox.fabricate! do |sandbox_group|
          #  sandbox_group.path = 'gitlab-qa-ip-restricted-sandbox-group'
          #end

          # This is our top-level group. By default, it creates a 'Sandbox' group
          @Parent_Group_A = Resource::Group.fabricate_via_api! do |group|
            group.path = "Parent-group-a-#{SecureRandom.hex(8)}"
          end

          # This is for GroupA, it creates a sub-group of the sandbox group (used as our top-level group)
          @GroupA = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Parent_Group_A
            group.path = "Sub-group-a-#{SecureRandom.hex(8)}"
          end

          # Same as for GroupA, it creates a nested group
          @ChildGroupA = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @GroupA
            group.path = "Sub-sub-group-a-#{SecureRandom.hex(8)}"
          end

          @ProjectA = Resource::Project.fabricate! do |project|
            project.name = 'ProjectA-on-ChilGroupA'
            project.description = 'Project in child group ChildGroupA'
            project.group = @ChildGroupA
            project.initialize_with_readme = true
            project.visibility = 'private'
          end

          # If we use Resource::Group it uses the same sandbox by default for each group we create, they will be all nested groups of the top-level 
          # sandbox. To use a different Sandbox, we have to specifically use Resource::Sandbox.
          @Parent_Group_B = Resource::Group.fabricate_via_api! do |group|
            group.path = "Parent-group-b-#{SecureRandom.hex(8)}"
          end

          @GroupB = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @ParentGroupB
            group.path = "Sub-group-b-#{SecureRandom.hex(8)}"
          end

          @ChildGroupB = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @GroupB
            group.path = "Sub-sub-group-b-#{SecureRandom.hex(8)}"
          end
  
          @ParentUserA = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
          @GroupUserA = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_2, Runtime::Env.gitlab_qa_password_2)
          @ChildGroupUserA = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_3, Runtime::Env.gitlab_qa_password_3)

          @ParentUserB = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_4, Runtime::Env.gitlab_qa_password_4)
          @GroupUserB = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_5, Runtime::Env.gitlab_qa_password_5)
          @ChildGroupUserB = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_6, Runtime::Env.gitlab_qa_password_6)

          # TODO: login
          Page::Main::Login.perform do |login|
            Flow::Login.sign_in_as_admin
            @Parent_Group_A.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@ParentUserB.username)
              # members_page.update_access_level(@ParentUserB.username, "Developer")
            end
          end
        end

        #after(:all) do
        #  @group.remove_via_api! 
        #  # TODO: remove groups
        #  # TODO: logout
        #end

        it 'ParentUserA invites members of the ParentGroupB to be part of ParentGroupA' do
          # TODO: tests
        end

        # it 'ParentUserA invites members of the GroupB to be part of ParentGroupA' do
        #   # TODO: tests
        # end

        # it 'ParentUserA invites members of the ChildGroupB to be part of ParentGroupA' do
        #   # TODO: tests
        # end
        
      end
    end
end