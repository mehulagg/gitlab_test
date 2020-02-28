# frozen_string_literal: true

module QA
  module Page
    module Group
      module SubMenus
        class Members < Page::Base
          include Page::Component::UsersSelect
          include Page::Component::Select2

          view 'app/views/groups/group_members/index.html.haml' do
            element :invite_group_tab
          end

          view 'app/views/shared/members/_invite_member.html.haml' do
            element :member_select_field
            element :invite_member_button
          end

          view 'app/views/shared/members/_member.html.haml' do
            element :member_row
            element :access_level_dropdown
            element :delete_member_button
            element :developer_access_level_link, 'qa_selector: "#{role.downcase}_access_level_link"' # rubocop:disable QA/ElementWithPattern, Lint/InterpolationCheck
          end

          #? for what is this needed ?
          view 'app/views/shared/members/_invite_group.html.haml' do
            element :group_select_field
            element :group_access_field
            element :invite_group_button
          end

          view 'app/views/shared/members/_group.html.haml' do
            element :access_level_dropdown
            element :group_row
            element :delete_group_access_link
            element :developer_group_access_level_link
          end

          def add_member(username)
            select_user :member_select_field, username
            click_element :invite_member_button
          end

          def update_access_level(username, access_level)
            within_element(:member_row, text: username) do
              click_element :access_level_dropdown
              click_element "#{access_level.downcase}_access_level_link"
            end
          end

          def remove_member(username)
            page.accept_confirm do
              within_element(:member_row, text: username) do
                click_element :delete_member_button
              end
            end
          end

          # TODO: ask the QA team about this method, there is no selector in the haml file which I believe makes this method not possible for now. A change is probably required
          def update_group_access_level(username, access_level)
            within_element(:group_row, text: username) do
              click_element :access_level_dropdown
              click_element "#{access_level.downcase}_group_access_level_link"
            end
          end

          def invite_group(group_name)
            click_element :invite_group_tab
            select_group(group_name)
            click_element :invite_group_button
          end

          def invite_group(group_name, access_level)
            click_element :invite_group_tab
            select_group(group_name)
            select_element(:group_access_field, access_level)
            click_element :invite_group_button
          end

          def select_group(group_name)
            click_element :group_select_field
            search_and_select(group_name)
          end

          def remove_group(username)
            page.accept_confirm do
              within_element(:group_row, text: username) do
                click_element :delete_group_access_link
              end
            end
          end
        end
      end
    end
  end
end
