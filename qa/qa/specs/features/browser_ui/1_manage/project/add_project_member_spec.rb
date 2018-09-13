# frozen_string_literal: true

module QA
  context :manage do
    describe 'Add project member' do
      it 'user adds project member' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)

        user = Factory::Resource::User.fabricate!

        Page::Menu::Main.perform { |main| main.sign_out }
        Page::Main::Login.act { sign_in_using_credentials }

        Factory::Resource::Project.fabricate! do |resource|
          resource.name = 'add-member-project'
        end

        Page::Menu::Side.act { click_members_settings }
        Page::Project::Settings::Members.perform do |page|
          page.add_member(user.username)
        end

        expect(page).to have_content("#{user.name} @#{user.username} Given access")
      end
    end
  end
end
