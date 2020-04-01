# frozen_string_literal: true

require 'spec_helper'

describe StaticSiteEditor do
  subject(:static_site_editor) { described_class.new(repository, ref, path) }

  let(:project) { create(:project, :public, :repository, name: 'project', namespace: namespace) }
  let(:namespace) { create(:namespace, name: 'namespace') }
  let(:repository) { project.repository }
  let(:ref) { 'master' }
  let(:path) { 'README.md' }

  describe '#data' do
    subject { static_site_editor.data }

    it 'returns data for the frontend component' do
      is_expected.to include(
        branch: 'master',
        commit: a_kind_of(String),
        namespace: 'namespace',
        path: 'README.md',
        project: 'project',
        project_id: project.id,
      )
    end
  end

  describe 'Validations' do
    subject { static_site_editor.errors }

    before do
      static_site_editor.valid?
    end

    context 'when branch is not a master' do
      let(:ref) { 'my-branch' }

      it { is_expected.to have_key(:branch) }
    end

    context 'when repository is empty' do
      let(:project) { create(:project_empty_repo) }

      it { is_expected.to have_key(:commit) }
    end

    context 'when file does not exist' do
      let(:path) { 'UNKNOWN.md' }

      it { is_expected.to have_key(:file) }
    end

    context 'when file does have .md extension' do
      let(:path) { 'CHANGELOG' }

      it { is_expected.to have_key(:extension) }
    end
  end
end
