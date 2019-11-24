# frozen_string_literal: true

module Geo
  class ReplicableEvent < ApplicationRecord
    include Geo::Model
    include ::EachBatch

    def self.latest_event
      order(id: :desc).first
    end

    def self.next_unprocessed_event
      # last_processed = Geo::ReplicableEventLogState.last_processed
      # return first unless last_processed

      # where('id > ?', last_processed.event_id).first
    end

    def consume
      event_class.new(self).consume
    end

    def event_class
      event_class_name.constantize
    end
  end
end
