# frozen_string_literal: true

module Gitlab
  class UserAccess
    extend Gitlab::Cache::RequestCache

    request_cache_key do
      [user&.id, project&.id]
    end

    attr_reader :user
    attr_accessor :project

    def initialize(user, project: nil)
      @user = user
      @project = project
    end

    def can_do_action?(action)
      return false unless can_access_git?

      permission_cache[action] =
        permission_cache.fetch(action) do
          Ability.allowed?(user, action, policy_subject)
        end
    end

    def cannot_do_action?(action)
      !can_do_action?(action)
    end

    def allowed?
      return false unless can_access_git?

      if user.requires_ldap_check? && user.try_obtain_ldap_lease
        return false unless Gitlab::Auth::Ldap::Access.allowed?(user)
      end

      true
    end

    protected

    request_cache def can_access_git?
      user && user.can?(:access_git)
    end

    def policy_subject
      project
    end

    private

    def permission_cache
      @permission_cache ||= {}
    end
  end
end
