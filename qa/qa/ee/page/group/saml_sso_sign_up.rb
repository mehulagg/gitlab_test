# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        class SamlSSOSignUp < QA::Page::Base
          view 'ee/app/views/groups/sso/sign_up_form.html.haml' do
            element :sign_out_and_register_button
            element :new_user_email_field
            element :new_user_username_field
          end

          def click_signout_and_register_button
            Support::Retrier.retry_until do
              click_element :sign_out_and_register_button
              !has_element?(:sign_out_and_register_button, wait: 0)
            end
          end

          def current_email
            find_element(:new_user_email_field)[:value]
          end

          def current_username
            find_element(:new_user_username_field)[:value]
          end
        end
      end
    end
  end
end
