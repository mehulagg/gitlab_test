# frozen_string_literal: true

module ProjectHelpers
  # @params target [Project] membership target
  # @params membership [Symbol] accepts the membership levels :guest, :reporter...
  #                             and phony levels :non_member and :anonymous
  def create_user_from_membership(target, membership)
    case membership
    when :anonymous
      nil
    when :non_member
      create(:user, name: membership)
    else
      create(:user, name: membership).tap { |u| target.add_user(u, membership) }
    end
  end

  def update_feature_access_level(project, access_level)
    project.update!(
      repository_access_level: access_level,
      merge_requests_access_level: access_level,
      builds_access_level: access_level
    )
  end

  def exists?(storage, name)
    storage_path = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
      Gitlab.config.repositories.storages[storage].legacy_disk_path
    end

    File.exist?(File.join(storage_path, name))
  end

  def rm_namespace(storage, name)
    storage_path = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
      Gitlab.config.repositories.storages[storage].legacy_disk_path
    end

    FileUtils.rm_r(File.join(storage_path, name))
  end
end
