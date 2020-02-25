require 'securerandom'

module QA
    context 'Manage' do
      # contexte should be Manage or Plan ?
      describe 'Sharing groups with groups with different permissions' do
        before(:all) do
          # If we use Resource::Group it uses the same sandbox by default for each group we create, they will be all nested groups of the top-level 
          # sandbox. To use a different Sandbox, we have to specifically use Resource::Sandbox.
          # This is our top-level group. By default, it creates a 'Sandbox' group
          @Parent_Group_A = QA::Resource::Group.fabricate_via_api! do |group|
            group.path = "Parent-group-a-Vitor-#{SecureRandom.hex(8)}"
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

          Flow::Login.sign_in_as_admin
          #  It uses the PAGE module, that means it's browsing through the UI, so we have to first visit the page, to have menus available and then we can simulate clicks to add users.
          #  We are using root user, so we can do that
          @Child_Group_B.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(@Child_Group_User_B.username)
            members_page.update_access_level(@Child_Group_User_B.username, "Owner")
          end

          @Group_B.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(@Group_User_B.username)
            members_page.update_access_level(@Group_User_B.username, "Owner")
          end

          @Parent_Group_B.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(@Parent_User_B.username)
            members_page.update_access_level(@Parent_User_B.username, "Owner")
          end

          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform do |settings_page|
            settings_page.set_group_visibility("private")
            settings_page.click_save_name_visibility_settings_button()
          end
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(@Child_Group_User_A.username)
            members_page.update_access_level(@Child_Group_User_A.username, "Owner")
            members_page.invite_group(@Child_Group_B.path)
            members_page.update_group_access_level(@Child_Group_B.path, "Guest") # Probably not need but just a safety assignement in case the framework changes
          end

          @Group_A.visit!
          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform do |settings_page|
            settings_page.set_group_visibility("private")
            settings_page.click_save_name_visibility_settings_button()
          end
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(@Group_User_A.username)
            members_page.update_access_level(@Group_User_A.username, "Owner")
            members_page.invite_group(@Group_B.path)
            members_page.update_group_access_level(@Group_B.path, "Guest")
          end

          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform do |settings_page|
            settings_page.set_group_visibility("private")
            settings_page.click_save_name_visibility_settings_button()
          end
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(@Parent_User_A.username)
            members_page.update_access_level(@Parent_User_A.username, "Owner")
            members_page.invite_group(@Parent_Group_B.path)
            members_page.update_group_access_level(@Parent_Group_B.path, "Guest")
          end

          Page::Main::Menu.perform(&:sign_out_if_signed_in)

          Flow::Login.sign_in(as: @Parent_User_A)
          @Parent_Group_A.visit!
          expect(page).to have_text(@Parent_Group_A.path)

        end

        #after(:all) do
        #  @Parent_Group_A.remove_via_api! #! Does not remove the group
        #  @Parent_Group_B.remove_via_api! #! Does not remove the group
        #  Page::Main::Menu.perform(&:sign_out)
        #end

        it 'ParentUserA invites members of the Parent_Group_B to be part of Parent_Group_A' do
              Page::Main::Menu.perform(&:sign_out_if_signed_in)

              Flow::Login.sign_in(as: @Group_User_B)
              @Project_A.visit!
              expect(page).to have_text('Page Not Found')
        end
      end
    end
end
