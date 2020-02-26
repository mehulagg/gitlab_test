# frozen_string_literal: true

module Gitlab
  module Repository
    # Git repository adapter for design management
    class DesignManagement < ::Repository
      extend ::Gitlab::Utils::Override

      # We define static git attributes for the design repository as this
      # repository is entirely GitLab-managed rather than user-facing.
      #
      # Enable all uploaded files to be stored in LFS.
      MANAGED_GIT_ATTRIBUTES = <<~GA.freeze
        /#{::DesignManagement.designs_directory}/* filter=lfs diff=lfs merge=lfs -text
      GA

      def initialize(project, full_path: nil, shard: nil, disk_path: nil)
        # TODO: we need to allow full_path and disk_path be overridden until we can fix rename/cache purging
        design_repository_full_path = full_path || project.full_path + EE::Gitlab::GlRepository::DESIGN.path_suffix
        repository_disk_path = disk_path || project.disk_path + EE::Gitlab::GlRepository::DESIGN.path_suffix
        repository_shard = shard || project.repository_storage

        super(design_repository_full_path, project, shard: repository_shard, disk_path: repository_disk_path)
      end

      # Override of a method called on Repository instances but sent via
      # method_missing to Gitlab::Git::Repository where it is defined
      def info_attributes
        @info_attributes ||= Gitlab::Git::AttributesParser.new(MANAGED_GIT_ATTRIBUTES)
      end

      # Override of a method called on Repository instances but sent via
      # method_missing to Gitlab::Git::Repository where it is defined
      def attributes(path)
        info_attributes.attributes(path)
      end

      # Override of a method called on Repository instances but sent via
      # method_missing to Gitlab::Git::Repository where it is defined
      def gitattribute(path, name)
        attributes(path)[name]
      end

      # Override of a method called on Repository instances but sent via
      # method_missing to Gitlab::Git::Repository where it is defined
      def attributes_at(_ref = nil)
        info_attributes
      end

      override :copy_gitattributes
      def copy_gitattributes(_ref = nil)
        true
      end

      # temporary
      override :repo_type
      def repo_type
        ::Gitlab::GlRepository::RepoType.new(
          name: :design,
          access_checker_class: ::Gitlab::GitAccessDesign,
          repository_resolver: -> (project) { ::Gitlab::Repository::DesignManagement.new(project) },
          suffix: :design
        ).freeze
      end
    end
  end
end
