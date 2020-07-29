# frozen_string_literal: true

module Types
  class IssueTypeCountsType < BaseObject
    graphql_name 'IssueTypeCountsType'
    description "Represents total number of issues for the represented issue types"

    # authorize :read_issue

    ::Issue::issue_types.each_key do |issue_type|
      field issue_type,
            GraphQL::INT_TYPE,
            null: true,
            description: "Number of issues with issue type #{issue_type.upcase} for the project"
    end

    field :all,
          GraphQL::INT_TYPE,
          null: true,
          description: 'Total number of issues for the project'
  end
end
