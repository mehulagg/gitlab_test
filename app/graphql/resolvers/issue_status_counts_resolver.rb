# frozen_string_literal: true

module Resolvers
  class IssueStatusCountsResolver < BaseResolver
    prepend IssueResolverArguments

    argument :author_username, [GraphQL::STRING_TYPE],
              required: false,
              description: 'Filter requirements by author username'
    argument :assignee_username, [GraphQL::STRING_TYPE],
              required: false,
              description: 'Filter requirements by assignee username'

    type Types::IssueStatusCountsType, null: true

    def continue_issue_resolve(parent, finder, **args)
      finder.parent_param = parent
      apply_lookahead(Gitlab::IssuablesCountForState.new(finder, parent))
    end
  end
end
