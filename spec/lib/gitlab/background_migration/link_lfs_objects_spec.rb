# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::LinkLfsObjects, :migration, schema: 2020_01_24_053514 do
  let(:lfs_objects) { table(:lfs_objects) }
  let(:lfs_objects_projects) { table(:lfs_objects_projects) }

  shared_examples_for 'linking LFS objects' do
    context 'when LFS object IDs matches existing LfsObject records' do
      before do
        %w[
          91eff75a492a3ed0dfcb544d7f31326bc4014c8551849c192fd1e48d4dd2c897
          96f74c6fe7a2979eefb9ec74a5dfc6888fb25543cf99b77586b79afea1da6f97
        ].each do |oid|
          lfs_objects.create(oid: oid, size: 100)
        end
      end

      it 'creates LfsObjectsProject records for specified projects' do
        expect { subject.perform([project.id, another_project.id]) }.to change { lfs_objects_projects.count }.by(4)
        expect(project.lfs_objects.pluck(:oid)).to match_array(lfs_objects.pluck(:oid))
        expect(another_project.lfs_objects.pluck(:oid)).to match_array(lfs_objects.pluck(:oid))
      end

      context 'and some LFS objects are already associated to project' do
        before do
          lfs_objects_projects.create(lfs_object_id: lfs_objects.first.id, project_id: project.id)
        end

        it 'only creates LfsObjectsProject records that do not exist yet' do
          expect { subject.perform([project.id, another_project.id]) }.to change { lfs_objects_projects.count }.by(3)
          expect(project.lfs_objects.pluck(:oid)).to match_array(lfs_objects.pluck(:oid))
          expect(another_project.lfs_objects.pluck(:oid)).to match_array(lfs_objects.pluck(:oid))
        end
      end
    end

    context 'when LFS object IDs do not match any existing LfsObject records' do
      it 'does not create LfsObjectsProject records for specified projects' do
        expect { subject.perform([project.id, another_project.id]) }.not_to change { lfs_objects_projects.count }
        expect(project.lfs_objects).to be_empty
        expect(another_project.lfs_objects).to be_empty
      end
    end
  end

  # rubocop:disable RSpec/FactoriesInMigrationSpecs
  let(:group) { create(:group) }

  context 'when project is using hashed storage' do
    let(:project) { create(:project, :repository) }
    let(:another_project) { create(:project, :repository, group: group) }

    it_behaves_like 'linking LFS objects'
  end

  context 'when project is using legacy storage' do
    let(:project) { create(:project, :repository, :legacy_storage) }
    let(:another_project) { create(:project, :repository, :legacy_storage, group: group) }

    it_behaves_like 'linking LFS objects'
  end

  context 'when project has no repository' do
    let(:project) { create(:project) }

    it 'does not create LfsObjectsProject records for specified project' do
      expect { subject.perform([project.id]) }.not_to change { lfs_objects_projects.count }
      expect(project.lfs_objects).to be_empty
    end
  end
  # rubocop:enable RSpec/FactoriesInMigrationSpecs
end
