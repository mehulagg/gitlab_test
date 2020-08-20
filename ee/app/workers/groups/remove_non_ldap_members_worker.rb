# frozen_string_literal: true

module Groups
  class RemoveNonLdapMembersWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include Gitlab::Allowable

    queue_namespace :groups
    feature_category :authentication_and_authorization

    def perform(group_id, owner_id)
      group = Group.find(group_id)
      owner = User.find(owner_id)

      return unless Feature.enabled?(:ldap_settings_unlock_groups_by_owners)
      return if group.unlock_membership_to_ldap
      return unless can?(owner, :admin_group_member, group)

      owner_ids = group.owners.pluck_primary_key

      non_ldap_ids = group.users_with_descendants.non_ldap.pluck(:id)

      return if non_ldap_ids.empty?

      group.members_with_descendants.find_each do |member|
        next if owner_ids.include? member.user_id

        Members::DestroyService.new(owner).execute(member)  if non_ldap_ids.include? member.user_id
      end
    end
  end
end
