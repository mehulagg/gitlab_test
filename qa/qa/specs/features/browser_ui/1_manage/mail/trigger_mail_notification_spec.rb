# frozen_string_literal: true

module QA
  context 'Manage', :docker do
    describe 'mail notification' do
      before do
        @mailhog_server = run_mailhog_service
        p @mailhog_server
      end

      it 'user receives email for project invitation' do
        # Add user to new project
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        user = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)

        project = Resource::Project.fabricate_via_api! do |resource|
          resource.name = 'email-notification-test'
        end
        project.visit!

        Page::Project::Menu.perform(&:go_to_members_settings)
        Page::Project::Settings::Members.perform do |page| # rubocop:disable QA/AmbiguousPageObjectName
          page.add_member(user.username)
        end

        expect(page).to have_content(/@#{user.username}(\n| )?Given access/)

        # Wait for Action Mailer to deliver messages
        mailhog_messages = Support::Retrier.retry_until(sleep_interval: 1) do
          mailhog_response = Net::HTTP.start(@mailhog_server.host_name, 8025, use_ssl: false) do |http|
            http.request(Net::HTTP::Get.new('/api/v2/messages'))
          end

          mailhog_data = JSON.parse(mailhog_response.body)

          mailhog_data if mailhog_data["total"] > 0
        end

        # Check json result from mailhog
        puts "FOO: #{mailhog_messages}"
        expect(mailhog_messages).not_to be_nil
      end

      after do
        remove_mailhog_service
      end

      def run_mailhog_service
        Service::DockerRun::MailHog.new.tap do |runner|
          runner.pull
          runner.register!
        end
      end

      def remove_mailhog_service
        Service::DockerRun::MailHog.new.remove!
      end
    end
  end
end
