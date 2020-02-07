# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200124053514_schedule_link_fork_lfs_objects.rb')

describe ScheduleLinkForkLfsObjects, :migration, :sidekiq do
  let(:projects) { table(:projects) }
  let(:fork_networks) { table(:fork_networks) }
  let(:fork_network_members) { table(:fork_network_members) }
  let(:source_project) { projects.create(id: 1, namespace_id: 1) }
  let(:lfs_enabled_project) { projects.create(id: 2, namespace_id: 2, lfs_enabled: true) }
  let(:another_project) { projects.create(id: 3, namespace_id: 3, lfs_enabled: nil) }
  let(:lfs_disabled_project) { projects.create(id: 4, namespace_id: 4, lfs_enabled: false) }
  let(:another_source_project) { projects.create(id: 5, namespace_id: 5) }
  let(:fork_network) { fork_networks.create(id: 1, root_project_id: source_project.id) }
  let(:another_fork_network) { fork_networks.create(id: 2, root_project_id: another_source_project.id) }

  before do
    stub_const("#{described_class}::BATCH_SIZE", 1)
    stub_const("#{described_class}::CONCURRENCY", 1)
    allow(Gitlab.config.lfs).to receive(:enabled).and_return(true)

    fork_network_members.create(fork_network_id: fork_network.id, project_id: source_project.id, forked_from_project_id: nil)
    fork_network_members.create(fork_network_id: fork_network.id, project_id: lfs_enabled_project.id, forked_from_project_id: source_project.id)
    fork_network_members.create(fork_network_id: fork_network.id, project_id: another_project.id, forked_from_project_id: source_project.id)
    fork_network_members.create(fork_network_id: fork_network.id, project_id: lfs_disabled_project.id, forked_from_project_id: source_project.id)
    fork_network_members.create(fork_network_id: another_fork_network.id, project_id: another_source_project.id, forked_from_project_id: nil)
  end

  it 'schedules background migration for each fork that has LFS enabled' do
    Sidekiq::Testing.fake! do
      migrate!

      expect(described_class::MIGRATION)
        .to be_scheduled_migration(
          [lfs_enabled_project.id]
        )
      expect(described_class::MIGRATION)
        .to be_scheduled_delayed_migration(
          30.seconds,
          [another_project.id]
        )
      expect(BackgroundMigrationWorker.jobs.size).to eq(2)
    end
  end
end
