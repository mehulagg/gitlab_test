# frozen_string_literal: true

module Types
  class EpicIssueLinkType < BaseObject
    graphql_name 'EpicIssueLink'
    description 'Relationship between an epic and an issue'

    authorize :read_epic_issue

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the epic-issue relation'

    field :epic, Types::EpicType, null: true,
          description: 'The epic that belongs to the relation'

    field :issue, Types::IssueType, null: true,
          description: "The issue that belongs to the relation"

    field :relative_position, GraphQL::STRING_TYPE, null: true,
          description: 'Position of the issue in the list of issues linked to the epic'
  end
end
