# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupReleasesFinder do
  let(:user)     { create(:user) }
  let(:params)   { {} }
  let(:options)  { {} }

  subject { described_class.new(group: group, current_user: user, params: params, options: options).execute }

  shared_examples_for 'when the user is not part of the project' do
    it 'returns no releases' do
      is_expected.to be_empty
    end
  end

  shared_examples_for 'when a tag parameter is passed' do
    let(:params) { { tag: 'v1.0.0' } }

    it 'only returns the release with the matching tag' do
      expect(subject).to eq([v1_0_0])
    end
  end

  describe 'without subgroups' do
    let(:group) { create :group }
    let(:project1)    { create(:project, :repository, namespace: group) }
    let(:project2)    { create(:project, :repository, namespace: group) }
    let!(:v1_0_0)     { create(:release, project: project1, tag: 'v1.0.0') }
    let!(:v1_1_0)     { create(:release, project: project1, tag: 'v1.1.0') }
    let!(:v6)         { create(:release, project: project2, tag: 'v6') }

    it_behaves_like 'when the user is not part of the project'

    context 'when the user is a project developer on 1 project' do
      before do
        project1.add_developer(user)
        v1_0_0.update_attribute(:released_at, 3.days.ago)
        v1_1_0.update_attribute(:released_at, 1.day.ago)
      end

      it 'sorts by release date' do
        expect(subject.size).to eq(2)
        expect(subject).to eq([v1_1_0, v1_0_0])
      end
    end

    context 'options' do
      it 'preloads associations' do
        expect(Release).to receive(:preloaded).once.and_call_original

        subject
      end

      context 'when preload is false' do
        let(:options) { { preload: false } }

        it 'does not preload associations' do
          expect(Release).not_to receive(:preloaded)

          subject
        end
      end
    end

    context 'when the user is a project developer on all projects' do
      before do
        project1.add_developer(user)
        project2.add_developer(user)
        v1_0_0.update_attribute(:released_at, 3.days.ago)
        v6.update_attribute(:released_at, 2.days.ago)
        v1_1_0.update_attribute(:released_at, 1.day.ago)
      end

      it 'sorts by release date' do
        expect(subject.size).to eq(3)
        expect(subject).to eq([v1_1_0, v6, v1_0_0])
      end

      it_behaves_like 'when a tag parameter is passed'
    end
  end

  describe 'with subgroups' do
    let(:options) { { include_subgroups: true } }

    context 'with a single-level subgroup' do
      let(:group) { create :group }
      let(:subgroup) { create :group, parent: group }
      let(:project1) { create(:project, :repository, namespace: group) }
      let(:project2) { create(:project, :repository, namespace: subgroup) }
      let!(:v1_0_0)  { create(:release, project: project1, tag: 'v1.0.0') }
      let!(:v6)      { create(:release, project: project2, tag: 'v6') }

      it_behaves_like 'when the user is not part of the project'

      context 'when the user a project developer in the subgroup project' do
        before do
          project2.add_developer(user)
        end

        it 'returns only the subgroup releases' do
          expect(subject).to match_array([v6])
        end
      end

      context 'when the user a project developer in both projects' do
        before do
          project1.add_developer(user)
          project2.add_developer(user)
          v1_0_0.update_attribute(:released_at, 3.days.ago)
          v6.update_attribute(:released_at, 2.days.ago)
        end

        it 'returns all releases' do
          expect(subject).to match_array([v1_0_0, v6])
        end

        it_behaves_like 'when a tag parameter is passed'
      end
    end

    context 'with a multi-level subgroup' do
      let(:group) { create :group }
      let(:subgroup) { create :group, parent: group }
      let(:subsubgroup) { create :group, parent: group }
      let(:project1) { create(:project, :repository, namespace: subgroup) }
      let(:project2) { create(:project, :repository, namespace: subsubgroup) }
      let!(:v1_0_0)  { create(:release, project: project1, tag: 'v1.0.0') }
      let!(:v6)      { create(:release, project: project2, tag: 'v6') }

      it_behaves_like 'when the user is not part of the project'

      context 'when the user a project developer in the subgroup project' do
        before do
          project2.add_developer(user)
        end

        it 'returns only the subgroup releases' do
          expect(subject).to match_array([v6])
        end
      end

      context 'when the user a project developer in both projects' do
        before do
          project1.add_developer(user)
          project2.add_developer(user)
          v1_0_0.update_attribute(:released_at, 3.days.ago)
          v6.update_attribute(:released_at, 2.days.ago)
        end

        it 'returns all releases' do
          expect(subject).to match_array([v1_0_0, v6])
        end

        it_behaves_like 'when a tag parameter is passed'
      end
    end
  end
end
