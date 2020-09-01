# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200910155617_backfill_jira_tracker_deployment_type.rb')

RSpec.describe BackfillJiraTrackerDeploymentType, :sidekiq, schema: 20200910155617 do
  let(:services) { table(:services) }
  let(:jira_tracker_data) { table(:jira_tracker_data) }
  let(:migration) { described_class.new }

  describe '#up' do
    before do
      stub_const("#{described_class}::BATCH_SIZE", 2)

      jira_tracker_data.create!(id: 1, service_id: services.create!.id, deployment_type: 0)
      jira_tracker_data.create!(id: 2, service_id: services.create!.id, deployment_type: 1)
      jira_tracker_data.create!(id: 3, service_id: services.create!.id, deployment_type: 2)
      jira_tracker_data.create!(id: 4, service_id: services.create!.id, deployment_type: 0)
    end

    it 'schedules BackfillJiraTrackerDeploymentType background jobs' do
      Sidekiq::Testing.fake! do
        freeze_time do
          migration.up

          expect(BackgroundMigrationWorker.jobs.size).to eq(2)
          expect(described_class::MIGRATION).to be_scheduled_migration(4)
          expect(described_class::MIGRATION).to be_scheduled_migration(1)
        end
      end
    end
  end
end
