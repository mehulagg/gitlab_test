# frozen_string_literal: true

class ImportExport::GroupExportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace

  feature_category :importers
  loggable_arguments 2
  sidekiq_options retry: false

  def perform(user_id, group_id)
    user = User.find(user_id)
    group = Group.find(group_id)

    ::Groups::ImportExport::BulkExportService.new(group: group, user: user).execute
  end
end
