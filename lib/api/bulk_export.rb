# frozen_string_literal: true

module API
  class BulkExport < Grape::API::Instance
    resource :groups, requirements: { id: %r{[^/]+} } do
      desc 'Start export' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      params do
        requires :id, type: String, desc: 'The ID of a group'
        optional :callback_url, type: String, desc: 'An endpoint to notify export completion'
      end
      post ':id/bulk_export' do
        authorize! :admin_group, user_group

        export_service = ImportExport::BulkExportService.new(
          group: user_group,
          user: current_user,
          callback_url: params[:callback_url]
        )

        if export_service.async_execute
          accepted!
        else
          render_api_error!('Something went wrong :(', 422)
        end
      end

      desc 'Notify Export Status' do
        detail 'A webhook for notifying the destination instance of the status of an export'
      end
      params do
        requires :importable_type, type: String, desc: 'What kind of importable this is notifying about (group or project)'
        requires :importable_id, type: Integer, desc: 'The ID of the project/group on the source instance'
      end
      post 'export_status' do
        import_service = ImportExport::ImportService.new(
          importable_type: params[:importable_type],
          importable_id: params[:importable_id]
        )

        if import_service.async_execute
          accepted!
        else
          # TODO: how do we handle this on the source instance? Reschedule the notify?
          render_api_error!('Something went wrong :(', 422)
        end
      end
    end
  end
end
