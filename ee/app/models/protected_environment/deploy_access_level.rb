# frozen_string_literal: true
class ProtectedEnvironment::DeployAccessLevel < ProtectedEnvironment::AccessLevel
  belongs_to :user
  belongs_to :group
  belongs_to :protected_environment

  def group_type?
    group_id.present?
  end
end
