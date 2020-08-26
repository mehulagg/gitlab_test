# frozen_string_literal: true

module ImportExport::Callback
  class ImportProjectService
    attr_reader :destination_group, :import_export_upload, :user, :params

    def initialize(destination_group:, import_export_upload:, user:, params:)
      @destination_group = destination_group
      @import_export_upload = import_export_upload
      @user = user
      @params = params
    end

    def execute
      project_params = {
        path: path,
        namespace_id: namespace.id,
        name: params['name'],
        file: import_export_upload.import_file
      }


      ::Projects::GitlabProjectsImportService.new(user, project_params).execute
    end

    private

    def namespace
      Namespace.find_by_full_path(parent_path)
    end

    def path
      full_path.join('/')
    end

    def parent_path
      if full_path.one?
        full_path.first
      else
        full_path.slice(0, full_path.size - 1)
      end
    end

    def full_path
      ([destination_group.full_path] << params['path'].split('/').slice(1..-1))
    end
  end
end
