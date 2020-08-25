# frozen_string_literal: true

module ImportExport
  class BulkExportService
    attr_reader :group, :user, :callback_host, :destination_group_id

    def initialize(group:, user:, callback_host:, destination_group_id:)
      @group = group
      @user = user
      @callback_host = callback_host
      @destination_group_id = destination_group_id
    end

    def async_execute
      BulkExportWorker.new.perform(user.id, group.id, callback_host, destination_group_id)
    end

    def execute
      # export top level namespace
      Groups::ImportExport::ExportService.new(group: group, user: user).execute

      notify_destination! if callback_host.present?

      schedule_project_exports!

      true
    end

    private

    def schedule_project_exports!
      Project.where(group: all_groups).find_each do |project|
        ProjectExportWorker.perform_async(
          user.id,
          project.id,
          after_export_strategy_params.merge('project_path' => project.full_path),
          {}
        )
      end
    end

    def after_export_strategy_params
      @after_export_strategy_params ||= {
        'klass' => 'Gitlab::ImportExport::AfterExportStrategies::ExportCallbackStrategy',
        'callback_host' => callback_host,
        'destination_group_id' => destination_group_id
      }
    end

    def all_groups
      @all_groups ||= Gitlab::ObjectHierarchy
        .new(::Group.where(id: group.id))
        .base_and_descendants(with_depth: true)
        .order_by(:depth)
    end

    def notify_destination!
      client = GitlabClient.new(host: callback_host)

      client.notify_export(
        importable_type: 'group',
        importable_id: group.id,
        destination_group_id: destination_group_id
      )
    end
  end
end
