# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20191127180927_backfill_operations_feature_flags_iid.rb')

describe BackfillOperationsFeatureFlagsIid, :migration do
  let(:namespaces) { table(:namespaces) }
  let(:projects)   { table(:projects) }
  let(:flags)      { table(:operations_feature_flags) }

  def setup
    namespace = namespaces.create!(name: 'foo', path: 'foo')
    project = projects.create!(namespace_id: namespace.id)

    project
  end

  it 'migrates successfully when there are no flags in the database' do
    setup

    disable_migrations_output { migrate! }

    expect(flags.count).to eq(0)
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

  it 'does not change an existing iid for a flag' do
    project = setup
    flag = flags.create!(project_id: project.id, active: true, name: 'test_flag', iid: 5)

    expect(flag.iid).to eq(5)

    disable_migrations_output { migrate! }

    flag.reload
    expect(flag.iid).to eq(5)
  end

  it 'backfills the iid for flags when some flags for the project already have an iid' do
    project = setup
    flag_a = flags.create!(project_id: project.id, active: true, name: 'test_flag', iid: 4)
    flag_b = flags.create!(project_id: project.id, active: false, name: 'other_flag')
    flag_c = flags.create!(project_id: project.id, active: false, name: 'another_flag', iid: 5)

    expect(flag_a.iid).to eq(4)
    expect(flag_b.iid).to be_nil
    expect(flag_c.iid).to eq(5)

    disable_migrations_output { migrate! }

    flag_a.reload
    flag_b.reload
    flag_c.reload
    expect(flag_a.iid).to eq(4)
    expect(flag_b.iid).to eq(6)
    expect(flag_c.iid).to eq(5)
  end
end
