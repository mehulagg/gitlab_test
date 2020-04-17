# frozen_string_literal: true

module QA
  module Page
    module Main
      class FormlessLogin < Page::Base
        # This workaround avoids failure in Test::Sanity::Selectors
        # as it requires a Page class to have views / elements defined. 
        view 'app/views/layouts/devise.html.haml'

        def self.path(user: Runtime::User)
          "/users/qa_sign_in?user[login]=#{user.username}&user[password]=#{user.password}&gitlab_qa_formless_login_token=#{Runtime::Env.gitlab_qa_token}"
        end
      end
    end
  end
end
