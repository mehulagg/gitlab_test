# frozen_string_literal: true

# QA file change to trigger package-and-qa

module QA
  RSpec.describe 'Manage', :smoke do
    describe 'basic user login' do
      it 'user logs in using basic credentials and logs out', status_issue: 'https://gitlab.com/mlapierre-test/testcases-test/-/issues/388' do
        Flow::Login.sign_in

        Page::Main::Menu.perform do |menu|
          expect(menu).to have_personal_area
        end

        Support::Retrier.retry_until(sleep_interval: 0.5) do
          Page::Main::Menu.perform(&:sign_out)

          Page::Main::Login.perform(&:can_sign_in?)
        end

        Page::Main::Login.perform do |form|
          expect(form.can_sign_in?).to be(true)
        end
      end
    end
  end
end
