# frozen_string_literal: true

class StaticSiteEditor
  include ActiveModel::Validations

  validates :commit, presence: true
  validate :only_master_branch
  validate :only_markdown
  validate :file_existence

  def initialize(repository, ref, path)
    @repository = repository
    @ref = ref
    @path = path
  end

  def data
    {
      branch: ref,
      path: path,
      commit: commit.id,
      project: project.path,
      namespace: project.namespace.path
    }
  end

  private

  attr_reader :repository, :ref, :path

  delegate :project, to: :repository

  def commit
    @commit ||= repository.commit(ref)
  end

  def only_master_branch
    return if ref == 'master'

    errors.add(:branch, 'Branch must be a master')
  end

  def only_markdown
    return if File.extname(path) == '.md'

    errors.add(:extension, 'File must have a markdown extension')
  end

  def file_existence
    return if commit.blank?
    return if repository.blob_at(commit.id, path).present?

    errors.add(:file, 'File is not found')
  end
end
