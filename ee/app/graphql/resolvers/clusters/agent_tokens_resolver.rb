# frozen_string_literal: true

module Resolvers
  module Clusters
    class AgentTokensResolver < BaseResolver
      type Types::Clusters::AgentTokenType, null: true

      alias_method :agent, :object

      delegate :project, to: :agent

      def resolve(**args)
        return ::Clusters::AgentToken.none unless can_read_agent_tokens?

        agent.agent_tokens
      end

      private

      def can_read_agent_tokens?
        project.feature_available?(:cluster_agents) && current_user.can?(:admin_cluster, project)
      end
    end
  end
end
