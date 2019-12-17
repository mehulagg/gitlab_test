# frozen_string_literal: true

module Geo
  module TrackingStateMachine
    extend ActiveSupport::Concern

    STATES = {
      started: 1,
      synced: 2,
      failed: 3,
      pending: 4
    }.with_indifferent_access.freeze

    included do
      state_machine :state, initial: :pending do
        state :started, value: STATES[:started]
        state :synced, value: STATES[:synced]
        state :failed, value: STATES[:failed]
        state :pending, value: STATES[:pending]

        before_transition any => :started do |registry, _|
          registry.last_synced_at = Time.now
        end

        before_transition any => :pending do |registry, _|
          registry.retry_at    = 0
          registry.retry_count = 0
        end

        event :start_sync! do
          transition [:synced, :failed, :pending] => :started
        end

        event :repository_updated! do
          transition [:synced, :failed, :started] => :pending
        end
      end
    end
  end
end
