# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200203041111_complete_migrate_security_scans.rb')

# rubocop: disable RSpec/FactoriesInMigrationSpecs
describe CompleteMigrateSecurityScans, :migration do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:pipelines) { table(:ci_pipelines) }
  let(:builds) { table(:ci_builds) }
  let(:job_artifacts) { table(:ci_job_artifacts) }
  let(:security_scans) { table(:security_scans) }

  let(:namespace) { namespaces.create!(name: "foo", path: "bar") }
  let(:project) { projects.create!(namespace_id: namespace.id) }
  let(:pipeline) { pipelines.create!(project_id: project.id, ref: 'master', sha: 'abababab') }

  describe '#up' do
    it 'processes remaining background migrations' do
      expect(Gitlab::BackgroundMigration).to receive(:steal).with('MigrateSecurityScans')

      migrate!
    end

    context 'unprocessed security job artifacts' do
      using RSpec::Parameterized::TableSyntax

      where(:scan_type_name, :report_type, :scan_type_number) do
        :sast | 5 | 1
        :dependency_scanning | 6 | 2
        :container_scanning | 7 | 3
        :dast | 8 | 4
      end

      with_them do
        let(:build) { builds.create! }
        let(:job_artifact) { job_artifacts.create!(project_id: project.id, file_type: report_type, job_id: build.id) }

        it 'migrates the job artifact' do
          fake_migrater = instance_double(Gitlab::BackgroundMigration::MigrateSecurityScans)
          expect(Gitlab::BackgroundMigration::MigrateSecurityScans).to receive(:new).and_return(fake_migrater)

          expect(fake_migrater).to receive(:perform).with(job_artifact.id)

          migrate!
        end
      end
    end

    context 'processed security job artifacts' do
      let(:build) { builds.create!(commit_id: pipeline.id) }

      before do
        job_artifacts.create!(project_id: project.id, file_type: 8, job_id: build.id)
        security_scans.create!(build_id: build.id, scan_type: 4, pipeline_id: pipeline.id)
      end

      it 'does not migrate the job artifact' do
        expect(Gitlab::BackgroundMigration::MigrateSecurityScans).not_to receive(:new)

        migrate!
      end
    end

    context 'unprocessed non-security job artifacts' do
      let(:build) { builds.create! }

      before do
        job_artifacts.create!(project_id: project.id, file_type: 1, job_id: build.id)
      end

      it 'migrates the job artifact' do
        expect(Gitlab::BackgroundMigration::MigrateSecurityScans).not_to receive(:new)

        migrate!
      end
    end
  end
end
