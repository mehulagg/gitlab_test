# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200130021120_schedule_migrate_security_scans')

# rubocop: disable RSpec/FactoriesInMigrationSpecs
describe ScheduleMigrateSecurityScans, :migration, :sidekiq do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:builds) { table(:ci_builds) }
  let(:job_artifacts) { table(:ci_job_artifacts) }

  let(:namespace) { namespaces.create!(name: "foo", path: "bar") }
  let(:project) { projects.create!(namespace_id: namespace.id) }
  let(:build) { builds.create! }

  context 'no security job artifacts' do
    before do
      job_artifacts.create!(project_id: project.id, job_id: build.id, file_type: 1)
    end

    it 'does not schedule migration' do
      Sidekiq::Testing.fake! do
        migrate!

        expect(BackgroundMigrationWorker.jobs).to be_empty
      end
    end
  end

  context 'security job artifacts' do
    let!(:sast_job_artifact) { job_artifacts.create!(project_id: project.id, job_id: build.id, file_type: 5) }
    let!(:dast_job_artifact) { job_artifacts.create!(project_id: project.id, job_id: build.id, file_type: 8) }

    before do
      stub_const("#{described_class.name}::BATCH_SIZE", 1)
      stub_const("#{described_class.name}::INTERVAL", 1.minute.to_i)
    end

    it 'schedules artifact for migration' do
      Sidekiq::Testing.fake! do
        Timecop.freeze do
          migrate!

          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(1.minute, sast_job_artifact.id)
          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(2.minutes, dast_job_artifact.id)
          expect(BackgroundMigrationWorker.jobs.size).to eq(2)
        end
      end
    end
  end
end
