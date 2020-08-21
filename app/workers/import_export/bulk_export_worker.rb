# frozen_string_literal: true

class ImportExport::BulkExportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace

  feature_category :importers
  loggable_arguments 2
  sidekiq_options retry: false

  def perform(user_id, group_id, callback_url)
    user = User.find(user_id)
    group = Group.find(group_id)

    ::Groups::ImportExport::BulkExportService.new(group: group, user: user, callback_url: callback_url).execute
  end
end
