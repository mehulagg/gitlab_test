# frozen_string_literal: true

module API
  class BulkImport < Grape::API::Instance
    resource :groups do
      desc 'Start import' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      params do
        requires :source_group_id, type: String, desc: 'The ID of the group to import into on the destination'
        requires :source_host, type: String, desc: 'An endpoint to notify export completion'
        requires :source_access_token, type: String, desc: 'The personal access token of the user with export rights on the source instance'
        requires :destination_group_path, type: String, desc: 'Path to save the group at in the destination instance'
        requires :destination_group_name, type: String, desc: 'User friendly name of the top level group on the destination instance'
      end
      post ':bulk_import' do
        import_service = ImportExport::BulkImportService.new(
          group_id: params[:source_group_id],
          user: current_user,
          host: params[:source_host],
          access_token: params[:source_access_token],
          destination_group_params: {
            path: params[:destination_group_path],
            name: params[:destination_group_name]
          }
        )

        if import_service.execute
          accepted!
        else
          render_api_error!('Something went wrong :(', 422)
        end
      end
    end
  end
end
