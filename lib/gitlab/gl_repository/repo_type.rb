# frozen_string_literal: true

module Gitlab
  class GlRepository
    class RepoType
      attr_reader :name,
                  :access_checker_class,
                  :repository_accessor,
                  :collection,
                  :prefix

      def initialize(name:, access_checker_class:, repository_accessor:, prefix: nil, collection: false)
        @name = name
        @access_checker_class = access_checker_class
        @repository_accessor = repository_accessor
        @collection = collection
        @prefix = prefix || name
      end

      def identifier_for_subject(subject)
        "#{prefix}-#{subject.id}"
      end

      def fetch_id(identifier)
        match = /\A#{prefix}-(?<id>\d+)\z/.match(identifier)
        match[:id] if match
      end

      def wiki?
        self == WIKI
      end

      def project?
        self == PROJECT
      end

      def snippet?
        self == PROJECT_SNIPPET || self == PERSONAL_SNIPPET
      end

      def path_suffix
        project? ? "" : ".#{prefix}"
      end

      def path_regex
        return /$/ if project?

        Regexp.new("\\.(#{prefix}#{'-\\d+' if collection})$")
      end

      def repository_for(subject)
        repository_accessor.call(subject)
      end
    end
  end
end

Gitlab::GlRepository::RepoType.prepend_if_ee('EE::Gitlab::GlRepository::RepoType')
