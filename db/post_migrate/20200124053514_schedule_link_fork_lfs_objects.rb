# frozen_string_literal: true

class ScheduleLinkForkLfsObjects < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION = 'LinkLfsObjects'
  BATCH_SIZE = 1000
  CONCURRENCY = 4
  INTERVAL = 30.seconds.to_i

  disable_ddl_transaction!

  class Project < ActiveRecord::Base
    include EachBatch

    self.table_name = 'projects'

    has_one :fork_network_member, class_name: 'ScheduleLinkForkLfsObjects::ForkNetworkMember'
  end

  class ForkNetworkMember < ActiveRecord::Base
    self.table_name = 'fork_network_members'
  end

  def up
    return unless Gitlab.config.lfs.enabled

    forks_with_lfs_enabled.each_batch(of: BATCH_SIZE) do |batch, index|
      project_ids = batch.pluck(:project_id)

      project_ids.each_slice(BATCH_SIZE / CONCURRENCY) do |ids|
        BackgroundMigrationWorker.perform_in(
          (index - 1) * ids.size * INTERVAL,
          MIGRATION,
          [ids]
        )
      end
    end
  end

  def down
    # no-op
  end

  private

  def forks_with_lfs_enabled
    projects = Project.joins(:fork_network_member)

    projects
      .where(lfs_enabled: true)
      .or(projects.where(lfs_enabled: nil))
      .where('fork_network_members.forked_from_project_id IS NOT NULL')
  end
end
