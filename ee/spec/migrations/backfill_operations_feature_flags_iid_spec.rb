# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20191217203850_backfill_operations_feature_flags_iid.rb')

describe BackfillOperationsFeatureFlagsIid, :migration do
  let(:namespaces)     { table(:namespaces) }
  let(:projects)       { table(:projects) }
  let(:flags)          { table(:operations_feature_flags) }
  let(:issues)         { table(:issues) }
  let(:merge_requests) { table(:merge_requests) }
  let(:internal_ids)   { table(:internal_ids) }

  def setup
    namespace = namespaces.create!(name: 'foo', path: 'foo')
    project = projects.create!(namespace_id: namespace.id)

    project
  end

  it 'backfills the iid for a flag' do
    project = setup
    flag = flags.create!(project_id: project.id, active: true, name: 'test_flag')

    expect(flag.iid).to be_nil

    disable_migrations_output { migrate! }

    flag.reload
    expect(flag.iid).to eq(1)
  end

  it 'backfills the iid for multiple flags' do
    project = setup
    flag_a = flags.create!(project_id: project.id, active: true, name: 'test_flag')
    flag_b = flags.create!(project_id: project.id, active: false, name: 'other_flag')

    expect(flag_a.iid).to be_nil
    expect(flag_b.iid).to be_nil

    disable_migrations_output { migrate! }

    flag_a.reload
    flag_b.reload
    expect(flag_a.iid).to eq(1)
    expect(flag_b.iid).to eq(2)
  end

  it 'backfills the iid for multiple flags accross projects' do
    project_a = setup
    project_b = setup
    flag_a = flags.create!(project_id: project_a.id, active: true, name: 'test_flag')
    flag_b = flags.create!(project_id: project_b.id, active: false, name: 'other_flag')

    expect(flag_a.iid).to be_nil
    expect(flag_b.iid).to be_nil

    disable_migrations_output { migrate! }

    flag_a.reload
    flag_b.reload
    expect(flag_a.iid).to eq(1)
    expect(flag_b.iid).to eq(1)
  end

  it 'generates iids properly for feature flags created after the migration' do
    project = setup

    disable_migrations_output { migrate! }

    flag = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'other_flag')

    expect(flag.iid).to eq(1)
  end

  it 'generates iids properly for feature flags created after the migration when flags are backfilled' do
    project = setup
    flag_a = flags.create!(project_id: project.id, active: true, name: 'test_flag')

    disable_migrations_output { migrate! }

    flag_b = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'other_flag')

    expect(flag_a.reload.iid).to eq(1)
    expect(flag_b.iid).to eq(2)
  end

  it 'generates iids properly for flags created after the migration across multiple projects' do
    project_a = setup
    project_b = setup
    flags.create!(project_id: project_a.id, active: true, name: 'first_flag')
    flags.create!(project_id: project_b.id, active: true, name: 'flag')
    flags.create!(project_id: project_b.id, active: true, name: 'another_flag')

    disable_migrations_output { migrate! }

    flag_a = Operations::FeatureFlag.create!(project_id: project_a.id, active: true, name: 'second_flag')
    flag_b = Operations::FeatureFlag.create!(project_id: project_b.id, active: true, name: 'last_flag')

    expect(flag_a.iid).to eq(2)
    expect(flag_b.iid).to eq(3)
  end

  it 'does not change an iid for an issue' do
    project = setup
    flag = flags.create!(project_id: project.id, active: true, name: 'test_flag')
    issue = issues.create!(project_id: project.id, iid: 8)
    internal_id = internal_ids.create!(project_id: project.id, usage: 0, last_value: issue.iid)

    disable_migrations_output { migrate! }

    expect(flag.reload.iid).to eq(1)
    expect(issue.reload.iid).to eq(8)
    expect(internal_id.reload.usage).to eq(0)
    expect(internal_id.last_value).to eq(8)
  end

  it 'does not change an iid for a merge request' do
    project_a = setup
    project_b = setup
    flag = flags.create!(project_id: project_a.id, active: true, name: 'test_flag')
    merge_request_a = merge_requests.create!(target_project_id: project_b.id, target_branch: 'master', source_branch: 'feature-1', title: 'merge request', iid: 1)
    merge_request_b = merge_requests.create!(target_project_id: project_b.id, target_branch: 'master', source_branch: 'feature-2', title: 'merge request', iid: 2)
    internal_id = internal_ids.create!(project_id: project_b.id, usage: 1, last_value: merge_request_b.iid)

    disable_migrations_output { migrate! }

    expect(flag.reload.iid).to eq(1)
    expect(merge_request_a.reload.iid).to eq(1)
    expect(merge_request_b.reload.iid).to eq(2)
    expect(internal_id.reload.usage).to eq(1)
    expect(internal_id.last_value).to eq(2)
  end

  context 'when the new code creates a flag post deploy but before the migration runs' do
    it 'does not change the flag iid' do
      project = setup
      flag = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'test_flag')

      disable_migrations_output { migrate! }

      expect(flag.reload.iid).to eq(1)
    end

    it 'backfills flags already in the database' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')

      disable_migrations_output { migrate! }

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
      expect(flag_c.reload.iid).to eq(1)
    end

    it 'backfills flags across multiple projects' do
      project_a = setup
      project_b = setup
      flag_a = flags.create!(project_id: project_a.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project_b.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project_a.id, active: true, name: 'flag_c')
      flag_d = Operations::FeatureFlag.create!(project_id: project_b.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(2)
      expect(flag_c.reload.iid).to eq(1)
      expect(flag_d.reload.iid).to eq(1)
    end

    it 'generates iids properly for feature flags created after the migration' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')

      disable_migrations_output { migrate! }

      flag_d = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_d')
      flag_e = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_e')

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
      expect(flag_c.reload.iid).to eq(1)
      expect(flag_d.iid).to eq(4)
      expect(flag_e.iid).to eq(5)
    end

    it 'backfills flags and properly generates iids for new flags across multiple projects' do
      project_a = setup
      project_b = setup
      flag_a = flags.create!(project_id: project_a.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project_b.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project_a.id, active: true, name: 'flag_c')
      flag_d = Operations::FeatureFlag.create!(project_id: project_b.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      flag_e = Operations::FeatureFlag.create!(project_id: project_a.id, active: true, name: 'flag_e')
      flag_f = Operations::FeatureFlag.create!(project_id: project_b.id, active: true, name: 'flag_f')
      flag_g = Operations::FeatureFlag.create!(project_id: project_a.id, active: true, name: 'flag_g')

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(2)
      expect(flag_c.reload.iid).to eq(1)
      expect(flag_d.reload.iid).to eq(1)
      expect(flag_e.iid).to eq(3)
      expect(flag_f.iid).to eq(3)
      expect(flag_g.iid).to eq(4)
    end
  end

  context 'when the new code creates a flag and then old code creates a flag post deploy but before the migration runs' do
    it 'backfills flags' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c = flags.create!(project_id: project.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(1)
      expect(flag_c.reload.iid).to eq(3)
    end

    it 'generates an iid for a new flag after the migration' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_d = flags.create!(project_id: project.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      flag_e = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_e')

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
      expect(flag_c.reload.iid).to eq(1)
      expect(flag_d.reload.iid).to eq(4)
      expect(flag_e.iid).to eq(5)
    end
  end

  context 'when the new code creates and deletes a flag post deploy but before the migration runs' do
    it 'backfills flags already in the database' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c.delete

      disable_migrations_output { migrate! }

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
    end

    it 'successfully creates a new flag after the migration' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c.delete

      disable_migrations_output { migrate! }

      flag_d = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_d')

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
      expect(flag_d.iid).to eq(4)
    end
  end

  context 'when the new code creates and deletes a flag and old code creates a flag post deploy but before the migration runs' do
    it 'backfills flags' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c.delete
      flag_d = flags.create!(project_id: project.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
      expect(flag_d.reload.iid).to eq(4)
    end

    it 'successfully creates a new flag after the migration' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c.delete
      flag_d = flags.create!(project_id: project.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      flag_e = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_e')

      expect(flag_a.reload.iid).to eq(2)
      expect(flag_b.reload.iid).to eq(3)
      expect(flag_d.reload.iid).to eq(4)
      expect(flag_e.iid).to eq(5)
    end
  end

  context 'when the new code creates and deletes a flag and then creates another flag post deploy but before the migration runs' do
    it 'successfully generates an iid for a new flag after the migration' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c.delete
      flag_d = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      expect(flag_a.reload.iid).to eq(3)
      expect(flag_b.reload.iid).to eq(4)
      expect(flag_d.reload.iid).to eq(2)
    end

    it 'successfully generates an iid for a new flag after the migration' do
      project = setup
      flag_a = flags.create!(project_id: project.id, active: true, name: 'flag_a')
      flag_b = flags.create!(project_id: project.id, active: true, name: 'flag_b')
      flag_c = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_c')
      flag_c.delete
      flag_d = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_d')

      disable_migrations_output { migrate! }

      flag_e = Operations::FeatureFlag.create!(project_id: project.id, active: true, name: 'flag_e')

      expect(flag_a.reload.iid).to eq(3)
      expect(flag_b.reload.iid).to eq(4)
      expect(flag_d.reload.iid).to eq(2)
      expect(flag_e.iid).to eq(5)
    end
  end
end
