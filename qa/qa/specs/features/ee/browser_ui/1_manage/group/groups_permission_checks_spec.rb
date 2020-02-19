require 'securerandom'

module QA
    context 'Manage' do #? Or Plan ?
      describe 'Sharing groups with groups with different permissions' do
        before(:all) do
          #create users(ParentUserA, GroupUserA, ProjectUserA, ParentUserB, GroupUserB, ProjectUserB)
          #create groups(Parent_Group_A, GroupProjectA, ProjectA, Parent_Group_B, GroupProjectB, ProjectB)
          #@sandbox_group = Resource::Sandbox.fabricate! do |sandbox_group|
          #  sandbox_group.path = 'gitlab-qa-ip-restricted-sandbox-group'
          #end

          # This is our top-level group. By default, it creates a 'Sandbox' group
          @Parent_Group_A = QA::Resource::Group.fabricate_via_api! do |group|
            group.path = "Parent-group-a-#{SecureRandom.hex(8)}"
          end

          # This is for Group_A, it creates a sub-group of the sandbox group (used as our top-level group)
          @Group_A = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Parent_Group_A
            group.path = "Sub-group-a-#{SecureRandom.hex(8)}"
          end

          # Same as for Group_A, it creates a nested group
          @Child_Group_A = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Group_A
            group.path = "Sub-sub-group-a-#{SecureRandom.hex(8)}"
          end

          @Project_A = Resource::Project.fabricate! do |project|
            project.name = 'ProjectA-on-Child_Group_A'
            project.description = 'Project in child group Child_Group_A'
            project.group = @Child_Group_A
            project.initialize_with_readme = true
            project.visibility = 'private'
          end

          # If we use Resource::Group it uses the same sandbox by default for each group we create, they will be all nested groups of the top-level 
          # sandbox. To use a different Sandbox, we have to specifically use Resource::Sandbox.
          @Parent_Group_B = Resource::Group.fabricate_via_api! do |group|
            group.path = "Parent-group-b-#{SecureRandom.hex(8)}"
          end

          @Group_B = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Parent_Group_B
            group.path = "Sub-group-b-#{SecureRandom.hex(8)}"
          end

          @Child_Group_B = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Group_B
            group.path = "Sub-sub-group-b-#{SecureRandom.hex(8)}"
          end
  
          @Parent_User_A = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
          @Group_User_A = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_2, Runtime::Env.gitlab_qa_password_2)
          @Child_Group_User_A = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_3, Runtime::Env.gitlab_qa_password_3)

          @Parent_User_B = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_4, Runtime::Env.gitlab_qa_password_4)
          @Group_User_B = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_5, Runtime::Env.gitlab_qa_password_5)
          @Child_Group_User_B = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_6, Runtime::Env.gitlab_qa_password_6)

          # TODO: login
          Page::Main::Login.perform do |login|
            Flow::Login.sign_in_as_admin
            #  It uses the PAGE module, that means it's browsing through the UI, so we have to first visit the page, to have menus available and then we can simulate clicks to add users.
            #  We are using root user, so we can do that
            #! For Parent_Group_A
            @Parent_Group_A.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@Parent_User_A.username)
              members_page.invite_group(@Parent_Group_B.path)
              members_page.update_group_access_level(@Parent_Group_B.path, "Developer")
              #members_page.update_access_level(@Parent_User_A.username, "Developer")
            end
            #! For Group_A
            @Group_A.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@Group_User_A.username)
              #members_page.invite_group(@Group_B.path)
            end
            #! For Child_Group_A
            @Child_Group_A.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@Child_Group_User_A.username)
              #members_page.invite_group(@Child_Group_B.path)
            end
            #! For Parent_Group_B
            @Parent_Group_B.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@Parent_User_B.username)
            end
            #! For Group_B
            @Group_B.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@Group_User_B.username)
            end
            #! For Child_Group_B
            @Child_Group_B.visit!
            Page::Group::Menu.perform(&:click_group_members_item)
            Page::Group::SubMenus::Members.perform do |members_page|
              members_page.add_member(@Child_Group_User_B.username)
            end

            #? Do we need to add an user to the project? I don't think because of inheritance

          end
        end

        #after(:all) do
        #  @group.remove_via_api! 
        #  # TODO: remove groups
        #  # TODO: logout
        #end

        it 'ParentUserA invites members of the Parent_Group_B to be part of Parent_Group_A' do
          # We loging as admin to invit the different B groups
          #Page::Main::Login.perform do |login|
            #Flow::Login.sign_in_as_admin
            #! For Parent_Group_A
            #@Parent_Group_A.visit!
            #Page::Group::Menu.perform(&:click_group_members_item)
            #Page::Group::SubMenus::Members.perform do |members_page|
            #@Parent_Group_A.add_member(@Parent_Group_B.id, Resource::Members::AccessLevel::DEVELOPER)
            #end
            #! For Group_A
            #@Group_A.visit!
            #Page::Group::Menu.perform(&:click_group_members_item)
            #Page::Group::SubMenus::Members.perform do |members_page|
              #members_page.invite_group(@Group_B.path)
            #end
            ##! For Child_Group_A
            #@Child_Group_A.visit!
            #Page::Group::Menu.perform(&:click_group_members_item)
            #Page::Group::SubMenus::Members.perform do |members_page|
              #members_page.invite_group(@Child_Group_B.path)
            #end
          #end

          # we visit the groups 
        end

        # it 'ParentUserA invites members of the Group_B to be part of Parent_Group_A' do
        #   # TODO: tests
        # end

        # it 'ParentUserA invites members of the Child_Group_B to be part of Parent_Group_A' do
        #   # TODO: tests
        # end
        
      end
    end
end
