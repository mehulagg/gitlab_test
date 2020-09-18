# frozen_string_literal: true

module Gitlab
  module Restore
    class ImportTask
      module CommandLine
        include Gitlab::ImportExport::CommandLineUtil
        extend self

        attr_accessor :logger

        def execute(cmd)
          logger.info ">>>>> CMD: #{cmd}"
          output, status = Gitlab::Popen.popen(cmd)
          logger.error(Gitlab::ImportExport::Error.new(output.to_s)) unless status == 0 # rubocop:disable Gitlab/ModuleWithInstanceVariables
          status == 0
        end
      end
      private_constant :CommandLine

      def initialize(username:, export_file:, group_path:, import_type:, logger:)
        unless File.exist?(export_file)
          raise ArgumentError, "Bundle #{export_file} does not exist"
        end

        @user = User.find_by!(username: username) # rubocop: disable CodeReuse/ActiveRecord

        @given_group_path = group_path
        @import_type = import_type.to_sym

        @export_file = export_file
        @logger = logger

        CommandLine.logger = logger
      end

      def execute
        CommandLine.mkdir_p(base_path)
        CommandLine.untar_zxf(archive: export_file, dir: base_path)

        import_groups if %i[group all].include?(import_type)
        import_all_projects if %i[project all].include?(import_type)
      ensure
        FileUtils.rm_rf(base_path)
      end

      private

      attr_reader :user, :export_file, :logger, :shared, :import_type

      def group
        @group ||= begin
          Group.find_by_full_path(@given_group_path) ||
            ::Groups::CreateService
            .new(user, name: @given_group_path.split('/').last, path: @given_group_path)
            .execute
        end
      end

      def import_groups
        filename = Dir.glob(bundle_path('*.tar.gz')).first

        group.import_export_upload =
          ImportExportUpload.new(import_file: File.new(filename))

        logger.info("Importing group tree from #{filename} in #{group.name}(#{group.id})")

        Groups::ImportExport::ImportService
          .new(group: group, user: user)
          .execute
      end

      def import_all_projects
        Dir.glob(bundle_path('projects', '*.tar.gz')).each do |filename|
          import_project(group: group, filename: filename)
        end

        group_descendants.each do |g|
          Dir.glob(bundle_path('projects', path_without_root(g.full_path), '*.tar.gz')).each do |filename|
            import_project(group: g, filename: filename)
          end
        end
      end

      def import_project(group:, filename:)
        project_path = project_path_from(filename)

        logger.info "> Importing project from #{filename} to #{group.full_path}/#{project_path}"

        project = Project.create!(
          creator: user,
          namespace_id: group.id,
          path: project_path,
          name: project_path,
          import_type: "gitlab_project"
        )

        project.import_export_upload =
          ImportExportUpload.new(import_file: File.new(filename))

        Projects::ImportService.new(project, user).execute
      end

      def path_without_root(path)
        if path.include?('/')
          path.partition('/')[-1]
        else
          path
        end
      end

      def project_path_from(filename)
        File
          .basename(filename)
          .match(%r{(?<path>.*).tar.gz})[:path]
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def group_descendants
        Gitlab::ObjectHierarchy
          .new(Group.where(id: group.id))
          .base_and_descendants(with_depth: true)
          .where.not(id: group.id) # descendants method doesn't accept 'with_depth' option
          .order(:depth)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def bundle_path(*path)
        File.join([base_path].concat(path).compact)
      end

      def base_path
        @base_path ||= Gitlab::ImportExport.export_path(
          relative_path: "#{group.path}-restore"
        )
      end
    end
  end
end
