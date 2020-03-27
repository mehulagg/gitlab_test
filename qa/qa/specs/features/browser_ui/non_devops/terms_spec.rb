# frozen_string_literal: true

module QA
  describe 'Terms page', :requires_admin do
    let(:user) do
      Flow::Login.while_signed_in_as_admin do
        Runtime::ApplicationSettings.set_application_settings(terms: 'Do you accept?', enforce_terms: true)
        Resource::User.fabricate_via_api!
      end
    end

    before do
      Page::Main::Login.perform do |login|
        login.fill_element :login_field, user.username
        login.fill_element :password_field, user.password
        login.click_element :sign_in_button, Page::Main::Terms
      end
    end

    after do
      Runtime::ApplicationSettings.set_application_settings(terms: '', enforce_terms: false)
      user.remove_via_api!
    end

    it 'can decline terms' do
      Page::Main::Terms.perform(&:decline_terms)

      Page::Main::Login.perform do |login_page|
        expect(login_page).to be_visible
      end
    end

    it 'can accept terms' do
      Page::Main::Terms.perform(&:accept_terms)

      Page::Main::Menu.perform do |menu|
        expect(menu).to be_signed_in
      end
    end
  end
end
