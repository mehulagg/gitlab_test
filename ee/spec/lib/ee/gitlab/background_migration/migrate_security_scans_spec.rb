# frozen_string_literal: true

require 'spec_helper'

# rubocop: disable RSpec/FactoriesInMigrationSpecs
describe Gitlab::BackgroundMigration::MigrateSecurityScans, :migration, schema: 20200130212450 do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:pipelines) { table(:ci_pipelines) }
  let(:builds) { table(:ci_builds) }
  let(:job_artifacts) { table(:ci_job_artifacts) }
  let(:security_scans) { table(:security_scans) }

  let(:namespace) { namespaces.create!(name: "foo", path: "bar") }
  let(:project) { projects.create!(namespace_id: namespace.id) }
  let(:pipeline) { pipelines.create!(project_id: project.id, ref: 'master', sha: 'aaaaaaaa') }
  let(:build) { builds.create!(commit_id: pipeline.id) }

  subject { described_class.new }

  describe '#perform' do
    context 'when job artifacts and builds are present' do
      using RSpec::Parameterized::TableSyntax

      where(:scan_type_name, :report_type, :scan_type_number) do
        :sast | 5 | 1
        :dependency_scanning | 6 | 2
        :container_scanning | 7 | 3
        :dast | 8 | 4
      end

      with_them do
        it 'creates a new security scan' do
          job_artifact = job_artifacts.create!(project_id: project.id, job_id: build.id, file_type: report_type)

          subject.perform(job_artifact.id)

          scan = Security::Scan.first
          expect(scan.build_id).to eq(build.id)
          expect(scan.pipeline_id).to eq(pipeline.id)
          expect(scan.scan_type).to eq(scan_type_name.to_s)
        end
      end
    end

    context 'job artifacts are not found' do
      it 'security scans are not created' do
        subject.perform(1, 2, 3)

        expect(Security::Scan.count).to eq(0)
      end
    end
  end

  context 'job artifacts are not security artifacts' do
    let!(:job_artifact) { job_artifacts.create!(project_id: project.id, job_id: build.id, file_type: 1) }

    it 'does not save a new security scan' do
      subject.perform(job_artifact.id)

      expect(Security::Scan.count).to eq(0)
    end
  end

  context 'security scan has already been saved' do
    let!(:job_artifact) { job_artifacts.create!(project_id: project.id, job_id: build.id, file_type: 5) }

    before do
      security_scans.create!(pipeline_id: pipeline.id, build_id: build.id, scan_type: 1)
    end

    it 'does not save a new security scan' do
      subject.perform(job_artifact.id)

      expect(Security::Scan.count).to eq(1)
    end
  end

  context 'there are no job artifacts' do
    it 'does not save a new security scan' do
      subject.perform

      expect(Security::Scan.count).to eq(0)
    end
  end
end
