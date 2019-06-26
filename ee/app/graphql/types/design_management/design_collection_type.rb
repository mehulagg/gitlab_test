# frozen_string_literal: true

module Types
  module DesignManagement
    class DesignCollectionType < BaseObject
      graphql_name 'DesignCollection'

      authorize :read_design

      field :project, Types::ProjectType, null: false
      field :issue, Types::IssueType, null: false
      field :designs,
            Types::DesignManagement::DesignType.connection_type,
            null: false,
            description: "All designs for this collection" do
        argument :include_hidden, GraphQL::BOOLEAN_TYPE,
          required: false,
          description: "Should we include hidden designs?"
      end
      # TODO: allow getting a single design by filename
      field :versions,
            Types::DesignManagement::VersionType.connection_type,
            resolver: Resolvers::DesignManagement::VersionResolver,
            description: "All versions related to all designs ordered newest first"

      def designs(include_hidden: false)
        include_hidden ? issue.designs : issue.current_designs
      end
    end
  end
end
