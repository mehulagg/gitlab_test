# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::SnippetsRepoRestorer do
  include GitHelpers

  describe 'bundle a snippet Git repo' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, namespace: user.namespace) }
    let_it_be(:snippet_with_repo) { create(:project_snippet, :repository, project: project, author: user) }
    let_it_be(:snippet_without_repo) { create(:project_snippet, project: project, author: user) }

    let(:shared) { project.import_export_shared }
    let(:exporter) { Gitlab::ImportExport::SnippetsRepoSaver.new(current_user: user, project: project, shared: shared) }
    let(:bundle_dir) { ::Gitlab::ImportExport.snippets_repo_bundle_path(shared.export_path) }
    let(:restorer) do
      described_class.new(user: user,
                          shared: shared,
                          project: project)
    end

    before do
      allow_next_instance_of(Gitlab::ImportExport::SnippetRepoRestorer) do |instance|
        allow(instance).to receive(:restore).twice
      end

      exporter.save
    end

    after do
      FileUtils.rm_rf(shared.export_path)
    end

    it 'calls SnippetRepoRestorer per each snippet with the bundle path' do
      expect(Gitlab::ImportExport::SnippetRepoRestorer).to receive(:new).with(hash_including(snippet: snippet_with_repo, path_to_bundle: bundle_path(snippet_with_repo)))
      expect(Gitlab::ImportExport::SnippetRepoRestorer).to receive(:new).with(hash_including(snippet: snippet_without_repo, path_to_bundle: bundle_path(snippet_without_repo)))

      restorer.restore
    end

    def bundle_path(snippet)
      File.join(bundle_dir, "#{snippet.hexdigest}.bundle")
    end
  end
end
