class LdapGroupSyncWorker
  include ApplicationWorker

  def perform(group_ids, provider = nil)
    return unless Gitlab::LDAP::Config.group_sync_enabled?

    groups = Group.where(id: Array(group_ids))

    if provider
      EE::Gitlab::LDAP::Sync::Proxy.open(provider) do |proxy|
        sync_groups(groups, proxy: proxy)
      end
    else
      sync_groups(groups)
    end
  end

  def sync_groups(groups, proxy: nil)
    groups.each { |group| sync_group(group, proxy: proxy) }
  end

  def sync_group(group, proxy: nil)
    logger.info "Started LDAP group sync for group #{group.name} (#{group.id})"

    if proxy
      EE::Gitlab::LDAP::Sync::Group.execute(group, proxy)
    else
      EE::Gitlab::LDAP::Sync::Group.execute_all_providers(group)
    end

    logger.info "Finished LDAP group sync for group #{group.name} (#{group.id})"
  end
end
