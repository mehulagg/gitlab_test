# frozen_string_literal: true

module Gitlab
  # @deprecated
  class GlRepository
    include Singleton

    # @deprecated
    PROJECT = RepoType.new(
      name: :project,
      access_checker_class: Gitlab::GitAccess,
      repository_resolver: -> (project) { project.repository }
    ).freeze

    # @deprecated
    WIKI = RepoType.new(
      name: :wiki,
      access_checker_class: Gitlab::GitAccessWiki,
      repository_resolver: -> (project) { project.wiki.repository },
      suffix: :wiki
    ).freeze

    # @deprecated
    SNIPPET = RepoType.new(
      name: :snippet,
      access_checker_class: Gitlab::GitAccessSnippet,
      repository_resolver: -> (snippet) { snippet.repository },
      container_resolver: -> (id) { Snippet.find_by_id(id) }
    ).freeze

    # @deprecated
    TYPES = {
      PROJECT.name.to_s => PROJECT,
      WIKI.name.to_s => WIKI,
      SNIPPET.name.to_s => SNIPPET
    }.freeze

    def self.types
      instance.types
    end

    def self.parse(gl_repository)
      type_name, _id = gl_repository.split('-').first
      type = types[type_name]

      unless type
        raise ArgumentError, "Invalid GL Repository \"#{gl_repository}\""
      end

      container = type.fetch_container!(gl_repository)

      [container, type]
    end

    # @deprecated
    def self.default_type
      PROJECT
    end

    # @deprecated
    def types
      TYPES
    end

    private_class_method :instance
  end
end

Gitlab::GlRepository.prepend_if_ee('::EE::Gitlab::GlRepository')
