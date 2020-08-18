# frozen_string_literal: true

module Clusters
  class Agent < ApplicationRecord
    self.table_name = 'cluster_agents'

    belongs_to :project, class_name: '::Project' # Otherwise, it will load ::Clusters::Project

    has_many :agent_tokens, class_name: 'Clusters::AgentToken'

    validates :name,
      presence: true,
      length: { maximum: 63 },
      uniqueness: { scope: :project_id },
      format: {
        with: Gitlab::Regex.cluster_agent_name_regex,
        message: Gitlab::Regex.cluster_agent_name_regex_message
      }

    validate :repository_has_matching_config_file

    private

    def repository_has_matching_config_file
      repo = project&.repository
      main_ref = repo&.root_ref

      return if main_ref && repo.blob_at(main_ref, "agents/#{name}/config.yaml")

      errors.add(
        :base,
        s_("ClusterAgent|The file 'agents/%{name}/config.yaml' is missing from this repository") % { name: name }
      )
    end
  end
end
