# frozen_string_literal: true

module QA
  context 'Manage', :group_saml, :orchestrated, :requires_admin do
    describe 'Group SAML SSO' do
      include Support::Api

      before(:all) do
        puts ">>>>>>>> 1. in before(:all) of describe 'Group SAML SSO'"

        @group = Resource::Sandbox.fabricate_via_api!
        @api_client = Runtime::API::Client.new(:gitlab, personal_access_token: Runtime::Env.admin_personal_access_token)
      end

      before do
        puts ">>>>>>>> 2. in before of describe 'Group SAML SSO'"
        logout_from_idp

        reset_idp_session

        page.visit Runtime::Scenario.gitlab_address
        Page::Main::Menu.perform(&:sign_out_if_signed_in)

        Page::Main::Login.perform(&:sign_in_using_credentials) unless Page::Main::Menu.perform(&:signed_in?)

        @group.visit!
      end

      context 'Non enforced SSO' do
        before do
          puts ">>>>>>>> 3. in before of context 'Non enforced SSO'"
        end

        it 'User logs in to group with SAML SSO' do
          Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)

          managed_group_url = EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
            saml_sso.set_id_provider_sso_url(EE::Runtime::Saml.idp_sso_url)
            saml_sso.set_cert_fingerprint(EE::Runtime::Saml.idp_certificate_fingerprint)
            saml_sso.click_save_changes

            saml_sso.user_login_url_link_text
          end

          page.visit managed_group_url

          EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

          login_to_idp_if_required_and_expect_success('user1', 'user1pass')

          page.visit managed_group_url

          EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

          expect(page).to have_content("Already signed in with SAML for #{Runtime::Namespace.sandbox_name}")
        end

        it 'Lets group admin test settings' do
          incorrect_fingerprint = Digest::SHA1.hexdigest(rand.to_s)
          Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)

          EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
            saml_sso.set_id_provider_sso_url(EE::Runtime::Saml.idp_sso_url)
            saml_sso.set_cert_fingerprint(incorrect_fingerprint)
            saml_sso.click_save_changes

            saml_sso.click_test_button
          end

          login_to_idp_if_required('user2', 'user2pass')

          expect(page).to have_content("Verify SAML Configuration")
          expect(page).to have_content("Fingerprint mismatch")
          expect(page).to have_content("<saml:Issuer>#{QA::EE::Runtime::Saml.idp_issuer}</saml:Issuer>")

          EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
            saml_sso.set_cert_fingerprint(EE::Runtime::Saml.idp_certificate_fingerprint)
            saml_sso.click_save_changes

            saml_sso.click_test_button
          end

          expect(page).to have_content("Verify SAML Configuration")
          expect(page).not_to have_content("Fingerprint mismatch")
        end
      end

      context 'Enforced SSO' do
        before(:all) do
          puts ">>>>>>>> 4. in before(:all) of context 'Enforced SSO'"

          page.visit Runtime::Scenario.gitlab_address
          @developer_user = Resource::User.fabricate_via_api!

          @group.add_member(@developer_user)

          Support::Retrier.retry_until(raise_on_failure: true) do
            @managed_group_url = setup_and_enable_enforce_sso
            enforced_sso_setup?
          end
        end

        context 'Access' do
          let(:project) do
            Resource::Project.fabricate! do |project|
              project.name = 'project-in-saml-enforced-group-for-access-test'
              project.description = 'project in SAML enforced group for access test'
              project.group = @group
              project.initialize_with_readme = true
              project.visibility = 'private'
            end
          end

          let(:sub_group) do
            Resource::Group.fabricate_via_api! do |group|
              group.sandbox = @group
              group.path = "saml-sub-group"
            end
          end

          let(:sub_group_project) do
            Resource::Project.fabricate! do |project|
              project.name = 'sub-group-project-in-saml-enforced-group-for-access-test'
              project.description = 'Sub Group project in SAML enforced group for access test'
              project.group = @sub_group
              project.initialize_with_readme = true
              project.visibility = 'private'
            end
          end

          shared_examples 'user access' do
            it 'is not allowed without SSO' do
              page.visit Runtime::Scenario.gitlab_address
              Page::Main::Menu.perform(&:sign_out_if_signed_in)
              Page::Main::Login.perform do |login|
                login.sign_in_using_credentials(user: user)
              end

              expected_single_signon_text = 'group allows you to sign in with your Single Sign-On Account'

              @group.visit!

              expect(page).to have_content(expected_single_signon_text)

              sub_group.visit!

              expect(page).to have_content(expected_single_signon_text)

              project.visit!

              expect(page).to have_content(expected_single_signon_text)

              sub_group_project.visit!

              expect(page).to have_content(expected_single_signon_text)
            end
          end

          before(:all) do
            puts ">>>>>>>> 5. in before(:all) of context 'Access'"
            @owner_user = Resource::User.fabricate_via_api!

            @group.add_member(@owner_user, Resource::Members::AccessLevel::OWNER)
          end

          after(:all) do
            puts "<<<<<<<< D. in AFTER(:all) of context 'Access'"

            @group.remove_member(@owner_user)
          end

          it_behaves_like 'user access' do
            let(:user) { @developer_user }
          end
          it_behaves_like 'user access' do
            let(:user) { @owner_user }
          end
        end

        it 'user clones and pushes to project within a group using Git HTTP' do
          @project = Resource::Project.fabricate! do |project|
            project.name = 'project-in-saml-enforced-group'
            project.description = 'project in SAML enforced group for git clone test'
            project.group = @group
            project.initialize_with_readme = true
          end

          @project.visit!

          expect do
            Resource::Repository::ProjectPush.fabricate! do |project_push|
              project_push.project = @project
              project_push.branch_name = "new_branch"
              project_push.user = @developer_user
            end
          end.not_to raise_error
        end

        context 'Group managed accounts' do
          before do
            puts ">>>>>>>> 6. in before of context 'Group managed accounts'"

            Support::Retrier.retry_until(raise_on_failure: true) do
              setup_and_enable_group_managed_accounts
              group_managed_accounts_setup?
            end

            Page::Main::Menu.perform(&:sign_out_if_signed_in)
            logout_from_idp
          end

          it 'removes existing users from the group, forces existing users to create a new account and allows to leave group' do
            expect(@group.list_members.map { |item| item["username"] }).not_to include(@developer_user.username)

            visit_managed_group_url

            EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

            login_to_idp_if_required('user3', 'user3pass')

            expect(page).to have_text("uses group managed accounts. You need to create a new GitLab account which will be managed by")

            @idp_user_email = EE::Page::Group::SamlSSOSignUp.perform(&:current_email)

            remove_user_if_exists(@idp_user_email)

            new_username = EE::Page::Group::SamlSSOSignUp.perform(&:current_username)

            EE::Page::Group::SamlSSOSignUp.perform(&:click_register_button)

            expect(page).to have_text("Sign up was successful! Please confirm your email to sign in.")

            confirm_user(new_username)

            visit_managed_group_url

            EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

            expect(page).to have_text("Signed in with SAML")

            Page::Group::Show.perform(&:leave_group)

            expect(page).to have_text("You left")

            Page::Main::Menu.perform(&:sign_out)

            visit_managed_group_url

            EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

            expect(page).to have_text("uses group managed accounts. You need to create a new GitLab account which will be managed by")
          end

          after(:all) do
            puts "<<<<<<<< C. in AFTER(:all) of context 'Group managed accounts'"

            disable_sso_setting('group_managed_accounts')

            %w[group_managed_accounts sign_up_on_sso group_scim].each do |flag|
              Runtime::Feature.remove(flag)
            end

            remove_user_if_exists(@idp_user_email)
          end
        end

        after(:all) do
          puts "<<<<<<<< B. in AFTER(:all) of context 'Enforced SSO'"

          @group.remove_member(@developer_user)

          disable_sso_setting('enforced_sso')

          %w[enforced_sso enforced_sso_requires_session].each do |flag|
            Runtime::Feature.remove(flag)
          end
        end
      end

      after(:all) do
        puts "<<<<<<<< A in AFTER(:all) of describe 'Group SAML SSO'"

        remove_group(@group) unless @group.nil?

        page.visit Runtime::Scenario.gitlab_address
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
      end
    end

    def login_to_idp_if_required(username, password)
      Vendor::SAMLIdp::Page::Login.perform { |login_page| login_page.login_if_required(username, password) }
    end

    def login_to_idp_if_required_and_expect_success(username, password)
      login_to_idp_if_required(username, password)
      expect(page).to have_content(/(SAML for #{Runtime::Env.sandbox_name} was added to your connected accounts)|(Already signed in with SAML for #{Runtime::Env.sandbox_name})/)
    end

    def remove_group(group)
      delete Runtime::API::Request.new(@api_client, "/groups/#{group.path}").url
    end

    def confirm_user(name)
      page.visit Runtime::Scenario.gitlab_address
      Page::Main::Menu.perform(&:sign_out_if_signed_in)
      Page::Main::Login.perform(&:sign_in_using_admin_credentials)

      Page::Main::Menu.perform(&:go_to_admin_area)
      Page::Admin::Menu.perform(&:go_to_users_overview)
      Page::Admin::Overview::Users::Index.perform do |index|
        index.search_user(name)
        index.click_user(name)
      end

      Page::Admin::Overview::Users::Show.perform(&:confirm_user)

      Page::Main::Menu.perform(&:sign_out)
    end

    def setup_and_enable_enforce_sso
      %w[enforced_sso enforced_sso_requires_session].each do |flag|
        Runtime::Feature.enable_and_verify(flag)
      end

      page.visit Runtime::Scenario.gitlab_address
      Page::Main::Login.perform(&:sign_in_using_credentials) unless Page::Main::Menu.perform(&:signed_in?)

      Support::Retrier.retry_on_exception do
        @group.visit!

        Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)

        EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
          saml_sso.enforce_sso
          saml_sso.set_id_provider_sso_url(EE::Runtime::Saml.idp_sso_url)
          saml_sso.set_cert_fingerprint(EE::Runtime::Saml.idp_certificate_fingerprint)

          saml_sso.click_save_changes

          saml_sso.user_login_url_link_text
        end
      end
    end

    def enforced_sso_setup?
      QA::Runtime::Logger.info("Verifying if enforced sso is setup correctly")

      @group.visit!

      Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)

      EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
        condition = saml_sso.enforce_sso_enabled?

        unless condition
          QA::Runtime::Logger.debug Capybara::Screenshot.screenshot_and_save_page
          QA::Runtime::Logger.debug("Enforced SSO not setup correctly")
        end

        condition
      end
    end

    def setup_and_enable_group_managed_accounts
      %w[group_managed_accounts sign_up_on_sso group_scim].each do |flag|
        Runtime::Feature.enable_and_verify(flag)
      end

      page.visit Runtime::Scenario.gitlab_address
      Page::Main::Login.perform(&:sign_in_using_credentials) unless Page::Main::Menu.perform(&:signed_in?)

      Support::Retrier.retry_on_exception do
        # We must sign in with SAML before enabling Group Managed Accounts
        page.visit @managed_group_url
        EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

        login_to_idp_if_required_and_expect_success('user1', 'user1pass')

        Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)
        EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
          saml_sso.enable_group_managed_accounts

          saml_sso.click_save_changes
        end
      end
    end

    def group_managed_accounts_setup?
      QA::Runtime::Logger.info("Verifying if group managed accounts is setup correctly")

      @group.visit!

      Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)

      EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
        condition = saml_sso.enforce_sso_enabled? && saml_sso.group_managed_accounts_enabled?

        unless condition
          QA::Runtime::Logger.debug Capybara::Screenshot.screenshot_and_save_page
          QA::Runtime::Logger.debug("Group managed accounts not setup correctly")
        end

        condition
      end
    end

    def remove_user_if_exists(username_or_email)
      QA::Runtime::Logger.debug("Removing user \"#{username_or_email}\" via API")

      response = parse_body(get Runtime::API::Request.new(@api_client, "/users?search=#{username_or_email}").url)

      delete Runtime::API::Request.new(@api_client, "/users/#{response.first[:id]}").url if response.any?
    end

    def create_a_user_via_api
      Resource::User.fabricate_via_api!
    end

    def logout_from_idp
      QA::Runtime::Logger.debug("Logging out of IDP by visiting \"#{EE::Runtime::Saml.idp_sign_out_url}\"")

      page.visit EE::Runtime::Saml.idp_sign_out_url
      Support::Waiter.wait_until { current_url == EE::Runtime::Saml.idp_signed_out_url }
    end

    def reset_idp_session
      Runtime::Logger.debug(%Q[Visiting IDP url at "#{EE::Runtime::Saml.idp_sso_url} to reset session"])

      page.visit EE::Runtime::Saml.idp_sso_url
      Support::Waiter.wait_until { current_url == EE::Runtime::Saml.idp_sso_url }

      Capybara.current_session.reset!
    end

    def visit_managed_group_url
      Runtime::Logger.debug(%Q[Visiting managed_group_url at "#{@managed_group_url}"])

      page.visit @managed_group_url
      Support::Waiter.wait_until { current_url == @managed_group_url }
    end

    def disable_sso_setting(setting_name)
      if Runtime::Feature.enabled?(setting_name)
        Runtime::Logger.info("Disabling #{setting_name}")

        page.visit Runtime::Scenario.gitlab_address

        Support::Retrier.retry_until(raise_on_failure: true) do
          Page::Main::Menu.perform(&:sign_out_if_signed_in)
          !Page::Main::Menu.perform(&:signed_in?)
        end
        Page::Main::Login.perform(&:sign_in_using_admin_credentials)

        @group.visit!

        Page::Group::Menu.perform(&:go_to_saml_sso_group_settings)
        EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
          saml_sso.public_send("disable_#{setting_name}") if saml_sso.public_send("has_#{setting_name}_button?")
          saml_sso.click_save_changes
        end
      end
    end
  end
end
