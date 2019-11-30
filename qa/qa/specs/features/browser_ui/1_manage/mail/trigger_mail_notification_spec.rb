# frozen_string_literal: true

module QA
  context 'Manage', :orchestrated, :smtp do
    describe 'mail notification' do
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
        mailhog_json = Support::Retrier.retry_until(sleep_interval: 1) do
          mailhog_response = Net::HTTP.start('mailhog.test', 8025, use_ssl: false) do |http|
            http.request(Net::HTTP::Get.new('/api/v2/messages'))
          end

          mailhog_data = JSON.parse(mailhog_response.body)

          # Expect at least two invitation messages: group and project
          mailhog_data if mailhog_data.dig('total') >= 2
        end

        # Check json result from mailhog
        mailhog_items = mailhog_json.dig('items')
        expect(mailhog_items).to include(an_object_satisfying { |o| /project was granted/ === o.dig('Content', 'Headers', 'Subject', 0) })
      end
    end
  end
end
