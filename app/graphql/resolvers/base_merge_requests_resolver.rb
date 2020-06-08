# frozen_string_literal: true

module Resolvers
  class BaseMergeRequestsResolver < BaseResolver
    include ResolvesMergeRequests

    # arguments that are relevant to any plural merge request resolver
    argument :iids, [GraphQL::STRING_TYPE],
              required: false,
              description: 'Array of IIDs of merge requests, for example `[1, 2]`'

    argument :source_branches, [GraphQL::STRING_TYPE],
             required: false,
             as: :source_branch,
             description: 'Array of source branch names. All resolved merge requests will have one of these branches as their source.'

    argument :target_branches, [GraphQL::STRING_TYPE],
             required: false,
             as: :target_branch,
             description: 'Array of target branch names. All resolved merge requests will have one of these branches as their target.'

    argument :state, ::Types::MergeRequestStateEnum,
             required: false,
             description: 'A merge request state. If provided, all resolved merge requests will have this state.'

    argument :labels, [GraphQL::STRING_TYPE],
             required: false,
             as: :label_name,
             description: 'Array of label names. All resolved merge requests will have all of these labels.'
  end
end
