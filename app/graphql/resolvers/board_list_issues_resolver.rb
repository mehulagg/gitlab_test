# frozen_string_literal: true

module Resolvers
  class BoardListIssuesResolver < BaseResolver
    include BoardIssueFilterable

    argument :filters, Types::Boards::BoardIssueInputType,
             required: false,
             description: 'Filters applied when selecting issues in the board list'

    argument :epic_ids, [GraphQL::ID_TYPE],
             required: false,
             description: 'Include issues only in selected epics'

    type Types::IssueType, null: true

    alias_method :list, :object

    def resolve(**args)
      filter_params = issue_filters(args[:filters]).merge(board_id: list.board.id, id: list.id, epic_ids: epic_ids(args))
      service = Boards::Issues::ListService.new(list.board.resource_parent, context[:current_user], filter_params)

      Gitlab::Graphql::Pagination::OffsetActiveRecordRelationConnection.new(service.execute)
    end

    # https://gitlab.com/gitlab-org/gitlab/-/issues/235681
    def self.complexity_multiplier(args)
      0.005
    end

    def epic_ids(args)
      return unless args[:epic_ids]

      args[:epic_ids].map { |gid| GitlabSchema.parse_gid(gid, expected_type: ::Epic).model_id }
    end
  end
end
