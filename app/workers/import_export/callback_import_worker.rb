# frozen_string_literal: true

class ImportExport::CallbackImportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace

  feature_category :importers
  loggable_arguments 2
  sidekiq_options retry: false

  def perform(importable_type, importable_id, destination_group_id)
    service = ImportExport::ImportService.new(
      importable_type: importable_type,
      importable_id: importable_id,
      destination_group_id: destination_group_id
    )

    service.execute
  end
end
