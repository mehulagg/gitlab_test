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
            group.path = "Parent-group-a-lala#{SecureRandom.hex(8)}"
          end

          # This is for Group_A, it creates a sub-group of the sandbox group (used as our top-level group)
          @Group_A = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Parent_Group_A
            group.path = "Group-a-lili#{SecureRandom.hex(8)}"
          end

          # Same as for Group_A, it creates a nested group
          @Child_Group_A = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Group_A
            group.path = "Sub-group-a-lolo#{SecureRandom.hex(8)}"
          end

          @Project_A = Resource::Project.fabricate! do |project|
            project.name = 'ProjectA-on-Child_Group_A'
            project.description = 'Project in child group Child_Group_A'
            project.group = @Child_Group_A
            project.initialize_with_readme = true
            project.visibility = 'private'
          end

          @Parent_Group_B = Resource::Group.fabricate_via_api! do |group|
            group.path = "Parent-group-b-lala#{SecureRandom.hex(8)}"
          end

          @Group_B = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Parent_Group_B
            group.path = "Group-b-lili#{SecureRandom.hex(8)}"
          end

          @Child_Group_B = Resource::Group.fabricate_via_api! do |group|
            group.sandbox = @Group_B
            group.path = "Sub-group-b-lolo#{SecureRandom.hex(8)}"
          end

          @Parent_User_B = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_4, Runtime::Env.gitlab_qa_password_4)
          @Group_User_B = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_5, Runtime::Env.gitlab_qa_password_5)
          @Child_Group_User_B = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_6, Runtime::Env.gitlab_qa_password_6)

          # We setup groups related to A
          sign_out_and_sign_in_as_admin()
          make_group_private(@Child_Group_A)
          make_group_private(@Group_A)
          make_group_private(@Parent_Group_A)
          Page::Main::Menu.perform(&:sign_out)
        end

        after(:all) do
          sign_out_and_sign_in_as_admin()
          @Parent_Group_A.remove_via_api!
          @Parent_Group_B.remove_via_api!
          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 1
        #! Duplicates: 16
        it 'ParentUserA invites members of the Parent_Group_B with a role of "Guest" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Guest"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, user_B_access_level, @Parent_Group_B)

          add_group_to_group(@Parent_Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          page.go_back
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Parent_Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 6
        #! Duplicates: 21
        it 'ParentGroupA invites members of the Group_B with a role of "Guest" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Guest"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          page.go_back
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 11
        #! Duplicates: 26
        it 'ParentGroupA invites members of the Child_Group_B with a role of "Guest" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Guest"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Child_Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          page.go_back
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Child_Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 31
        #! Duplicates: none
        it 'ChildGroupA invites members of the Parent_Group_B with a role of "Guest" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Guest"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, user_B_access_level, @Parent_Group_B)

          add_group_to_group(@Parent_Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          #page.go_back
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Parent_Group_B.path, @Child_Group_A)
          #remove_user_from_group(@Child_Group_User_A.username, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end
        # Line 36
        #! Duplicates: none
        it 'ChildGroupA invites members of the Group_B with a role of "Guest" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Guest"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          page.go_back
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Group_B.path, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 41
        #! Duplicates: none
        it 'ChildGroupA invites members of the Child_Group_B with a role of "Guest" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Guest"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Child_Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back
          
          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          #page.go_back
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Child_Group_B.path, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 61
        #! Duplicates: line 76
        it 'ParentGroupA invites members of the Parent_Group_B with a role of "Reporter" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Reporter"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, user_B_access_level, @Parent_Group_B)

          add_group_to_group(@Parent_Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Parent_Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 66
        #! Duplicates: line 81
        it 'ParentGroupUserA invites members of the Group_B with a role of "Reporter" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Reporter"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 71
        #! Duplicates: line 86
        it 'ParentGroupUserA invites members of the Child_Group_B with a role of "Reporter" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Reporter"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Child_Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Child_Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 91
        #! Duplicates: none
        it 'ChildGroupUserA invites members of the Parent_Group_B with a role of "Reporter" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Reporter"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, user_B_access_level, @Parent_Group_B)

          add_group_to_group(@Parent_Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Parent_Group_B.path, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 96
        #! Duplicates: none
        it 'ChildGroupUserA invites members of the Group_B with a role of "Reporter" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Reporter"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Group_B.path, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 101
        #! Duplicates: none
        it 'ChildGroupUserA invites members of the Child_Group_B with a role of "Reporter" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Reporter"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Child_Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Child_Group_B.path, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 121
        #! Duplicates: 136
        it 'ParentGroupUserA invites members of the Parent_Group_B with a role of "Developer" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Developer"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, user_B_access_level, @Parent_Group_B)

          add_group_to_group(@Parent_Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Parent_Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 126
        #! Duplicates: 141
        it 'ParentGroupUserA invites members of the Group_B with a role of "Developer" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Developer"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 131
        #! Duplicates: 146
        it 'ParentGroupUserA invites members of the Child_Group_B with a role of "Developer" within B group to be part of Parent_Group_A as "Guest"' do
          user_B_access_level = "Developer"
          max_access_level = "Guest"

          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

          add_group_to_group(@Child_Group_B.path, max_access_level, @Parent_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Parent_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Child_Group_B.path, @Parent_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 151
        #! Duplicates: none
        it 'ChildGroupUserA invites members of the Parent_Group_B with a role of "Developer" within B group to be part of Child_Group_A as "Guest"' do
          user_B_access_level = "Developer"
          max_access_level = "Guest"
          sign_out_and_sign_in_as_admin()
          # We setup users related to B
          add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
          add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
          add_user_to_group(@Parent_User_B.username, user_B_access_level, @Parent_Group_B)

          add_group_to_group(@Parent_Group_B.path, max_access_level, @Child_Group_A)

          # We perform the tests
          sign_out_and_sign_in_as_another_user(@Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          sign_out_and_sign_in_as_another_user(@Parent_User_B)
          @Project_A.visit!
          expect(page).to have_text(@Project_A.name)
          # we go to check what access level the group has
          @Child_Group_A.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          expect(page).to have_text(max_access_level)
          page.go_back

          sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
          @Project_A.visit!
          expect(page).to have_text('Page Not Found')
          page.go_back

          # We cleanup the setup part
          sign_out_and_sign_in_as_admin()
          remove_group_from_group(@Parent_Group_B.path, @Child_Group_A)

          remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
          remove_user_from_group(@Group_User_B.username, @Group_B)
          remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

          Page::Main::Menu.perform(&:sign_out)
        end

        # Line 156
        #! Duplicates: none
         it 'Child_Group_A invites members of the Group_B with a role of "Developer" within B group to be part of Child_Group_A as "Guest"' do
           user_B_access_level = "Developer"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
           add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Group_B.path, max_access_level, @Child_Group_A)

        #    # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           #Runtime::Logger.debug("@Group User B visiting Project A")
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           #Runtime::Logger.debug("@Group User B visiting Child Group A")
           @Child_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back 
                                     

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back               
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Group_B.path, @Child_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

        # Line 161
        #! Duplicates: none
         it 'Child_Group_A invites members of the Child_Group_B with a role of "Developer" within B group to be part of Parent_Group_A as "Guest"' do
           user_B_access_level = "Developer"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
           add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Child_Group_B.path, max_access_level, @Child_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
                           

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Child_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back                 
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Child_Group_B.path, @Child_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

         # Line 201
        #! Duplicates: 186
         it 'Parent_Group_A invites members of the Group_B with a role of "Maintainer" within B group to be part of Parent_Group_A as "Guest"' do
           user_B_access_level = "Maintainer"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
           add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Group_B.path, max_access_level, @Parent_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Parent_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back 
                                     

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back                   
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Group_B.path, @Parent_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end
         
        # Line 206
        #! Duplicates: 191
         it 'Parent_Group_A invites members of the Child_Group_B with a role of "Maintainer" within B group to be part of Parent_Group_A as "Guest"' do
           user_B_access_level = "Maintainer"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
           add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Child_Group_B.path, max_access_level, @Parent_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
                           

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Parent_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back                   
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Child_Group_B.path, @Parent_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

         
        # Line 216
        #! Duplicates: None
         it 'Child_Group_A invites members of the Group_B with a role of "Maintainer" within B group to be part of Parent_Group_A as "Guest"' do
           user_B_access_level = "Maintainer"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
           add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Group_B.path, max_access_level, @Child_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Child_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back 
                                     

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
                    
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Group_B.path, @Child_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

         # Line 221
        #! Duplicates: None
         it 'Child_Group_A invites members of the Child_Group_B with a role of "Maintainer" within B group to be part of Parent_Group_A as "Guest"' do
           user_B_access_level = "Maintainer"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
           add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Child_Group_B.path, max_access_level, @Child_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
                           

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Child_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back          
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Child_Group_B.path, @Child_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

         # Line 261
        #! Duplicates: 246
         it 'Parent_Group_A invites members of the Group_B with a role of "Owner" within B group to be part of Parent_Group_A as "Guest"' do
           user_B_access_level = "Owner"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
           add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Group_B.path, max_access_level, @Parent_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Parent_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back
                 

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
           
          
          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Group_B.path, @Parent_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

        # Line 266
        #! Duplicates: 251
         it 'Parent_Group_A invites members of the Child_Group_B with a role of "Owner" within B group to be part of Child_Group_A as "Guest"' do
           user_B_access_level = "Owner"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
           add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Child_Group_B.path, max_access_level, @Parent_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
       

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Parent_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back
           
                     
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Child_Group_B.path, @Parent_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end



        # Line 276
        #! Duplicates: none
         it 'Child_Group_A invites members of the Group_B with a role of "Owner" within B group to be part of Child_Group_A as "Guest"' do
           user_B_access_level = "Owner"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, "Guest", @Child_Group_B)
           add_user_to_group(@Group_User_B.username, user_B_access_level, @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Group_B.path, max_access_level, @Child_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Child_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back
           

          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Group_B.path, @Child_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

        # Line 281
        #! Duplicates: none
         it 'Child_Group_A invites members of the Child_Group_B with a role of "Owner" within B group to be part of Child_Group_A as "Guest"' do
           user_B_access_level = "Owner"
           max_access_level = "Guest"
           sign_out_and_sign_in_as_admin()
        #   # We setup users related to B
           add_user_to_group(@Child_Group_User_B.username, user_B_access_level, @Child_Group_B)
           add_user_to_group(@Group_User_B.username, "Guest", @Group_B)
           add_user_to_group(@Parent_User_B.username, "Guest", @Parent_Group_B)

           
           add_group_to_group(@Child_Group_B.path, max_access_level, @Child_Group_A)

        #   # We perform the tests      
           sign_out_and_sign_in_as_another_user(@Group_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back

           sign_out_and_sign_in_as_another_user(@Parent_User_B)
           @Project_A.visit!
           expect(page).to have_text('Page Not Found')
           page.go_back  
           
           sign_out_and_sign_in_as_another_user(@Child_Group_User_B)
           @Project_A.visit!
           expect(page).to have_text(@Project_A.name)
           @Child_Group_A.visit!
           Page::Group::Menu.perform(&:click_group_members_item)
           expect(page).to have_text(max_access_level)
           page.go_back

          
        #   # We cleanup the setup part
           sign_out_and_sign_in_as_admin()
           remove_group_from_group(@Child_Group_B.path, @Child_Group_A)
          
           remove_user_from_group(@Child_Group_User_B.username, @Child_Group_B)
           remove_user_from_group(@Group_User_B.username, @Group_B)
           remove_user_from_group(@Parent_User_B.username, @Parent_Group_B)

           Page::Main::Menu.perform(&:sign_out)
         end

        def sign_out_and_sign_in_as_admin()
          if Page::Main::Menu.perform(&:signed_in?)
            if !Page::Main::Menu.perform(&:has_admin_area_link?)
              Page::Main::Menu.perform(&:sign_out)
              Flow::Login.sign_in_as_admin
            end
          else
            Flow::Login.sign_in_as_admin
          end
        end
  
        def sign_out_and_sign_in_as_another_user(another_user)
          # Not working for an unknown reason
          Page::Main::Menu.perform(&:sign_out_if_signed_in)
          Flow::Login.sign_in(as: another_user)
        end
  
        def make_group_private(group)
          group.visit!
          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform do |settings_page|
            settings_page.set_group_visibility("private")
            settings_page.click_save_name_visibility_settings_button()
          end
        end
  
        def add_user_to_group(username, access, group)
          #  It uses the PAGE module, that means it's browsing through the UI, so we have to first visit the page, to have menus available and then we can simulate clicks to add users.
          #  We are using root user, so we can do that
          group.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.add_member(username)
            members_page.update_access_level(username, access)
          end
        end
  
        def add_group_to_group(invited_group_path, access_level, group)
          group.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.invite_group(invited_group_path, access_level)
            #members_page.update_group_access_level(invited_group_path, access)
          end
        end
  
        def remove_group_from_group(group_to_remove_path, group)
          group.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.remove_group(group_to_remove_path)
          end
        end

        def remove_user_from_group(username_to_remove, group)
          group.visit!
          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::SubMenus::Members.perform do |members_page|
            members_page.remove_member(username_to_remove)
          end
        end
        #QA_DEBUG=true CHROME_HEADLESS=true bundle exec bin/qa Test::Instance::All http://127.0.0.1:3000/ -- qa/specs/features/ee/browser_ui/1_manage/group/groups_permission_checks_spec.rb
      end
    end
end
