# frozen_string_literal: true

module Resolvers
  module Users
    class AuthoredMergeRequestsResolver < Resolvers::Users::MergeRequestsResolver
      include MergeRequestUserArguments

      user_mr_argument :assignee

      def user_role
        :author
      end
    end
  end
end
