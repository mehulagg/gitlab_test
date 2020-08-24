# frozen_string_literal: true

module ImportExport::Callback
  class ImportGroupService
    attr_reader :destination_group, :import_export_upload, :user

    def initialize(destination_group:, import_export_upload:, user:)
      @destination_group = destination_group
      @import_export_upload = import_export_upload
      @user = user
    end

    def execute
      # associate the import file with the existing group
      import_export_upload.update!(group: destination_group)

      # do the import
      ::Groups::ImportExport::ImportService.new(group: destination_group, user: user).execute
    end
  end
end
