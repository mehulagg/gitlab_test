# frozen_string_literal: true

module Groups
  module ImportExport
    class ExportService
      def initialize(group:, user:, params: {})
        @group        = group
        @current_user = user
        @params       = params
      end

      def execute
        @shared = Gitlab::ImportExport::Shared.new(@group)

        save!
      end

      private

      attr_accessor :shared

      def save!
        if tree_exporter.save
          Gitlab::ImportExport::Saver.save(exportable: @group, shared: shared)
          notify_success
        else
          cleanup_and_notify_error!
        end
      end

      def tree_exporter
        Gitlab::ImportExport::GroupTreeSaver.new(group: @group, current_user: @current_user, shared: @shared, params: @params)
      end

      def cleanup_and_notify_error
        @shared.logger.error(
          group_id:   @group.id,
          group_name: @group.name,
          error:      @shared.errors.join(', '),
          message:    'Group Import/Export: Export failed'
        )

        FileUtils.rm_rf(shared.export_path)

        notify_error
      end

      def cleanup_and_notify_error!
        cleanup_and_notify_error

        raise Gitlab::ImportExport::Error.new(shared.errors.to_sentence)
      end

      def notify_success
        @shared.logger.info(
          group_id:   @group.id,
          group_name: @group.name,
          message:    'Group Import/Export: Export succeeded'
        )
      end

      def notify_error
        # TBD
      end
    end
  end
end
