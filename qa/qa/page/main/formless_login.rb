# frozen_string_literal: true

module QA
  module Page
    module Main
      class FormlessLogin < Page::Base
        # The below code is a workaround to avoid a failure in the
        # qa:selectors job on CI.
        # The point is that the element defined but not used.
        view 'app/views/layouts/devise.html.haml' do
          element :login_page
        end

        def self.path(user: nil)
          user ||= Runtime::User

          "/users/qa_sign_in?user[login]=#{user.username}&user[password]=#{user.password}&gitlab_qa_formless_login_token=#{Runtime::Env.gitlab_qa_token}"
        end
      end
    end
  end
end
