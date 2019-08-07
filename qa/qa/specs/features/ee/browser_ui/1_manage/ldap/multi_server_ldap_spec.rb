# frozen_string_literal: true

module QA
  context 'Manage', :orchestrated, :ldap_multi do
    describe 'Multi LDAP server login' do
      it 'user logs into GitLab using first LDAP server credentials' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)

        Page::Main::Login.perform do |login_page|
          user = Struct.new(:ldap_username, :ldap_password).new('user1', 'password')

          login_page.sign_in_using_ldap_multi_credentials(user, 'ldap')
        end

        Page::Main::Menu.perform do |menu|
          expect(menu).to have_personal_area
        end
      end

      it 'user logs into GitLab using second LDAP server credentials' do
        Page::Main::Menu.perform do |menu|
          menu.sign_out if menu.has_personal_area?
        end

        Runtime::Browser.visit(:gitlab, Page::Main::Login)

        Page::Main::Login.perform do |login_page|
          user = Struct.new(:ldap_username, :ldap_password).new('user2', 'password')

          login_page.sign_in_using_ldap_multi_credentials(user, 'ldap2')
        end

        Page::Main::Menu.perform do |menu|
          expect(menu).to have_personal_area
        end
      end
    end
  end
end
