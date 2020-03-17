# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'post_migrate', '20200309162730_backfill_target_type_on_push_rules.rb')

describe BackfillTargetTypeOnPushRules do
  let(:push_rules) { table(:push_rules) }

  it 'adds type to global rule' do
    sample_rule = push_rules.create!(is_sample: true)

    Sidekiq::Testing.fake! do
      disable_migrations_output { migrate! }
    end

    sample_rule.reload
    expect(sample_rule.target_type).to eq(described_class::INSTANCE_TYPE)
  end

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
