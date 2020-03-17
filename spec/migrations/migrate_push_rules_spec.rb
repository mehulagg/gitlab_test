# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'post_migrate', '20200309162723_migrate_push_rules.rb')

describe MigratePushRules do
  let(:push_rules) { table(:push_rules) }

  it 'schedules worker to migrate project push rules' do
    rule_1 = push_rules.create!
    rule_2 = push_rules.create!

    Sidekiq::Testing.fake! do
      disable_migrations_output { migrate! }

      expect(BackgroundMigrationWorker.jobs.size).to eq(1)
      expect(described_class::MIGRATION)
        .to be_scheduled_delayed_migration(5.minutes, rule_1.id, rule_2.id)
    end
  end
end
