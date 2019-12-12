# frozen_string_literal: true

module Repositorable
  extend ActiveSupport::Concern
  include Gitlab::ShellAdapter
  include AfterCommitQueue

  def valid_repo?
    repository.exists?
  rescue
    errors.add(:path, _('Invalid repository path'))
    false
  end

  def repository_exists?
    strong_memoize(:repository_exists) do
      !!repository.exists?
    rescue
      false
    end
  end

  def root_ref?(branch)
    repository.root_ref == branch
  end

  def commit(ref = 'HEAD')
    repository.commit(ref)
  end

  def commit_by(oid:)
    repository.commit_by(oid: oid)
  end

  def commits_by(oids:)
    repository.commits_by(oids: oids)
  end

  def repository
    raise NotImplementedError
  end

  def empty_repo?
    repository.empty?
  end

  def default_branch
    @default_branch ||= repository.root_ref
  end

  def reload_default_branch
    @default_branch = nil # rubocop:disable Gitlab/ModuleWithInstanceVariables

    default_branch
  end
end
