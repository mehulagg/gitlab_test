# frozen_string_literal: true

module ImportExport::Callback
  class ImportService
    IMPORT_HANDLERS = {
      project: ImportProjectService,
      group: ImportGroupService
    }.freeze

    attr_reader :source_type, :source_id, :destination_group_id, :params

    def initialize(importable_type:, importable_id:, destination_group_id:, params:)
      @source_type = importable_type.to_sym
      @source_id = importable_id
      @destination_group_id = destination_group_id
      @params = params
    end

    def async_execute
      ImportExport::Callback::ImportWorker.perform_async(source_type, source_id, destination_group_id, params)
    end

    def execute
      # TODO: we want to validate that the file we're getting here is safe
      # - Maybe with a request ID to identify our own files?


      # download the export file
      upload = ImportExportUpload.new
      uploader = upload.import_file

      uploader.download!(client.download_export_file_url(source_type, source_id), client.headers)
      uploader.store!

      # call the right importer
      importer = importer_class.new(
        destination_group: destination_group,
        import_export_upload: upload,
        user: bulk_import.user,
        params: params
      )

      importer.execute
    end

    private

    def client
      @client ||= ImportExport::GitlabClient.new(host: bulk_import.source_host, access_token: bulk_import.private_token)
    end

    def bulk_import
      @bulk_import ||= destination_group.bulk_import
    end

    def destination_group
      @destination_group ||= Group.find_by_full_path(destination_group_id)
    end

    def importer_class
      IMPORT_HANDLERS.fetch(source_type.to_sym)
    end
  end
end
