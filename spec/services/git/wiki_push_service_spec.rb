# frozen_string_literal: true

require 'spec_helper'

describe Git::WikiPushService do
  include RepoHelpers

  let(:gl_repository) { "wiki-#{project.id}" }
  let(:key) { create(:key, user: current_user) }
  let(:key_id) { key.shell_id }

  let_it_be(:project) { create(:project, :wiki_repo) }
  let(:current_user) { create(:user) }
  let(:post_received) { ::Gitlab::GitPostReceive.new(project, key_id, changes, {}) }

  let_it_be(:repository) { project.wiki.repository.raw }
  let_it_be(:repository_path) { File.join(TestEnv.repos_path, repository.relative_path) }
  let_it_be(:repository_rugged) { Rugged::Repository.new(repository_path) }

  let(:changes) { +"123456 789012 refs/heads/tést\n654321 210987 refs/tags/tag\n423423 797823 refs/heads/master" }

  before do
    allow(post_received).to receive(:identify).with(key_id).and_return(current_user)
  end

  context 'changes to some pages have been pushed' do
    it 'does something useful' do
      new_commit_edit_new_file(repository_rugged, 'page_1.md', 'add page 1', 'Page One')
      new_commit_edit_new_file(repository_rugged, 'page_2.md', 'add page 2', 'Page One')
      binding.pry
    end
  end
end
