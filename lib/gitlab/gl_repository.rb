# frozen_string_literal: true

module Gitlab
  class GlRepository
    include Singleton

    PROJECT = RepoType.new(
      name: :project,
      access_checker_class: Gitlab::GitAccessProject,
      repository_resolver: -> (project) { ::Repository.new(project.full_path, project, shard: project.repository_storage, disk_path: project.disk_path) }
    ).freeze
    WIKI = RepoType.new(
      name: :wiki,
      access_checker_class: Gitlab::GitAccessWiki,
      repository_resolver: -> (container) { ::Repository.new(container.wiki.full_path, container, shard: container.wiki.repository_storage, disk_path: container.wiki.disk_path, repo_type: WIKI) },
      project_resolver: -> (container) { container.is_a?(Project) ? container : nil },
      suffix: :wiki
    ).freeze
    SNIPPET = RepoType.new(
      name: :snippet,
      access_checker_class: Gitlab::GitAccessSnippet,
      repository_resolver: -> (snippet) { ::Repository.new(snippet.full_path, snippet, shard: snippet.repository_storage, disk_path: snippet.disk_path, repo_type: SNIPPET) },
      container_class: Snippet,
      project_resolver: -> (snippet) { snippet&.project },
      guest_read_ability: :read_snippet
    ).freeze
    DESIGN = ::Gitlab::GlRepository::RepoType.new(
      name: :design,
      access_checker_class: ::Gitlab::GitAccessDesign,
      repository_resolver: -> (project) { ::DesignManagement::Repository.new(project) },
      suffix: :design
    ).freeze

    TYPES = {
      PROJECT.name.to_s => PROJECT,
      WIKI.name.to_s => WIKI,
      SNIPPET.name.to_s => SNIPPET,
      DESIGN.name.to_s => DESIGN
    }.freeze

    def self.types
      instance.types
    end

    def self.parse(gl_repository)
      identifier = ::Gitlab::GlRepository::Identifier.parse(gl_repository)

      repo_type = identifier.repo_type
      container = identifier.container

      [container, repo_type.project_for(container), repo_type]
    end

    def self.default_type
      PROJECT
    end

    def types
      TYPES
    end

    private_class_method :instance
  end
end
