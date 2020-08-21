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

      non_ldap_user_ids = group.direct_and_indirect_users.non_ldap.pluck(:id)

      return if non_ldap_user_ids.empty?

      Member.from_union([
                          ProjectMember
                            .joins(project: :group)
                            .where(namespaces: { id: group.self_and_descendants.select(:id) },
                                   user_id: non_ldap_user_ids),
                          group
                            .members_with_descendants
                            .where(user_id: non_ldap_user_ids)
                        ]).find_each do |member|
        next if owner_ids.include? member.user_id

        Members::DestroyService.new(owner).execute(member)
      end
    end
  end
end
