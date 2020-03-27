# frozen_string_literal: true

module QA
  module Page::Main
    class Terms < Page::Base
      view 'app/views/layouts/terms.html.haml' do
        element :user_avatar, required: true
      end

      view 'app/views/users/terms/index.html.haml' do
        element :terms_content, required: true

        element :continue_button
        element :accept_terms_button
        element :decline_and_sign_out_button
      end

      def accept_terms
        click_element :accept_terms_button, Page::Main::Menu
      end

      def decline_terms
        click_element :decline_and_sign_out_button, Page::Main::Login
      end
    end
  end
end
