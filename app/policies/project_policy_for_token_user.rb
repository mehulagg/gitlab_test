# frozen_string_literal: true

require_dependency 'declarative_policy'

# Used when Project is accessed via a project token.
# `user` here will be an instance of `ProjectTokenUser`
class ProjectPolicyForTokenUser < DeclarativePolicy::Base
  condition(:readable) do
    user.has_access_to?(project)
  end

  condition(:housekeep_project) do
    user.pat.housekeep_project
  end

  rule { readable }.policy do
    enable :read_project
  end

  rule { housekeep_project }.policy do
    enable :housekeep_project
  end

  def project
    @subject
  end
end
