# frozen_string_literal: true

module QA
  module Page
    module Main
      class FormlessLogin < Page::Base
        def self.path
          user = Runtime::User

          "/users/qa_sign_in?user[login]=#{user.username}&user[password]=#{user.password}&gitlab_qa_token=#{Runtime::Env.gitlab_qa_token}"
        end
      end
    end
  end
end
