# frozen_string_literal: true

class GroupActivityDataCollectionCronWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue

  queue_namespace :cronjob

  def perform
    GroupActivityDataCollectionWorker.bulk_perform_async_with_contexts(
      groups,
      arguments_proc: -> (group) { group.id },
      context_proc: -> (group) { { group: group } }
    )
  end

  private

  def groups
    # TODO add query for all eligible groups
  end
end
