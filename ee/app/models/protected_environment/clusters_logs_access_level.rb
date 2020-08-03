# frozen_string_literal: true

class ProtectedEnvironment::ClustersLogsAccessLevel < ProtectedEnvironment::AccessLevel
  belongs_to :user, inverse_of: :protected_environment_clusters_logs_access_level
  belongs_to :group, inverse_of: :protected_environment_clusters_logs_access_level, foreign_key: :namespace_id
  belongs_to :protected_environment, inverse_of: :clusters_logs_access_levels

  def group_type?
    namespace_id.present?
  end
end
