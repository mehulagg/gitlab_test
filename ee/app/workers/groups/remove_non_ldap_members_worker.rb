# frozen_string_literal: true

module Groups
  class RemoveNonLdapMembersWorker
    include ApplicationWorker
    include Gitlab::Allowable

    queue_namespace :groups
    feature_category :authentication_and_authorization

    idempotent!

    def perform(group_id, owner_id)
      group = Group.find_by_id(group_id)
      owner = User.find_by_id(owner_id)

      return if group.nil? || owner.nil?

      return unless Feature.enabled?(:ldap_settings_unlock_groups_by_owners)
      return if group.unlock_membership_to_ldap
      return unless can?(owner, :admin_group_member, group)

      owner_ids = group.owners.pluck_primary_key

      group.non_ldap_members_with_descendants.find_each do |member|
        next if owner_ids.include? member.user_id

        Members::DestroyService.new(owner).execute(member)
      end
    end
  end
end
