# frozen_string_literal: true

module API
  class BulkGroupExport < Grape::API::Instance
    before do
      authorize! :admin_group, user_group
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups, requirements: { id: %r{[^/]+} } do
      desc 'Start export' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      post ':id/bulk_export' do
        export_service = ::Groups::ImportExport::BulkExportService.new(group: user_group, user: current_user)

        if export_service.async_execute
          accepted!
        else
          render_api_error!(message: 'Something went wrong', status: 422)
        end
      end
    end
  end
end
