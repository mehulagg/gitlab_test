# frozen_string_literal: true

##
# Publish asynchronously events to each registered listener.
# To subscribe to an event simply add a listener class to the event.
#
# @example
#   # create an event and register a listener
#   class Ci::PipelineCreatedEvent < BaseEvent
#     def listeners
#       [
#         Ci::MetricsListener,
#         # ...
#       ]
#     end
#   end
#
# A listener can be any class or module that responds to
# to the method `.handle_event(event, data)` where:
#   - `event` is the class representing the event type (subclass of BaseEvent)
#   - `data` is a serialized information related to the event.
#     It is important for `data` to be serialized as it will be sent as parameter
#     to a Sidekiq worker.
#
# It's possible to have a listener per event so it can handle only 1 type of event,
# or to register it to multiple events and in that case allow it to handle multiple
# events. This could be an option when similar logic is used across different events.
#
# @example
#   class Ci::MetricsListener
#     def self.handle_event(event, data)
#       case event
#       when Ci::PipelineCreatedEvent
#         # do something with data
#       ...
#       end
#     end
#   end
#
# Finally, to publish an event:
#
# @example
#   data = { pipeline_id: pipeline.id, errors: [] }
#   Gitlab::EventPublisher.publish_event(Ci::PipelineCreatedEvent, data)
#
module Gitlab
  module EventPublisher
    def publish_event(event, data)
      event.listeners.each do |listener|
        EventPublisherWorker.perform_async(listener.name, event.name, data)
      end
    end

    module_function :publish_event
  end
end
