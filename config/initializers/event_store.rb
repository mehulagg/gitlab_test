# frozen_string_literal: true

# Subscribe to events being published via Gitlab::EventStore
Gitlab::EventStore.instance.tap do |store|
  # Example 1: Subscribe to all instances of an event
  #
  #   store.subscribe ChatNotificationWorker, to: Ci::BuildFinishedEvent
  #
  # Example 2: Subscribe to an event but consume the messages if a condition is
  #            satisfied
  #
  #   store.subscribe ChatNotificationWorker, to: Ci::BuildFinishedEvent, if: ->(event) { event.data[:origin] == :chat }
  #
  # Example 3: Subscribe to multiple events using the same worker
  #
  #   store.subscribe UnlockArtifactsWorker, to: [BranchDeletedEvent, TagDeletedEvent]

  store.subscribe Ci::UnlockArtifactsWorker, to: [
    Git::BranchPushedEvent,
    Git::TagPushedEvent,
    Repositories::BranchDeletedEvent,
    Repositories::TagDeletedEvent
  ]
end
