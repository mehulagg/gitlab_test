# frozen_string_literal: true

module Resolvers
  module Users
    class AssignedMergeRequestsResolver < Resolvers::Users::MergeRequestsResolver
      include MergeRequestUserArguments

      user_mr_argument :author

      def user_role
        :assignee
      end
    end
  end
end
