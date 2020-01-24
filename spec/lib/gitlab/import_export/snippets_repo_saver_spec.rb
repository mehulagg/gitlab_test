# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::SnippetsRepoSaver do
  describe 'bundle a project Git repo' do
    let_it_be(:user) { create(:user) }
    let!(:project) { create(:project) }
    let(:shared) { project.import_export_shared }
    let(:bundler) { described_class.new(current_user: user, project: project, shared: shared) }

    after do
      FileUtils.rm_rf(shared.export_path)
    end

    it 'creates the snippet bundles dir if not exists' do
      snippets_dir = ::Gitlab::ImportExport.snippets_repo_bundle_path(shared.export_path)
      expect(Dir.exist?(snippets_dir)).to be_falsey

      bundler.save

      expect(Dir.exist?(snippets_dir)).to be_truthy
    end

    context 'when project does not have any snippet' do
      it 'does not perform any action' do
        expect(Gitlab::ImportExport::SnippetRepoSaver).not_to receive(:new)

        bundler.save
      end
    end

    context 'when project has snippets' do
      it 'calls the SnippetRepoSaver for each snippet' do
        create(:project_snippet, :repository, project: project, author: user)
        create(:project_snippet, project: project, author: user)
        service = double

        allow(Gitlab::ImportExport::SnippetRepoSaver).to receive(:new).and_return(service)
        expect(service).to receive(:save).twice

        bundler.save
      end
    end
  end
end
