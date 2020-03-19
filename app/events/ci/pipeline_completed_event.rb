# frozen_string_literal: true

module Ci
  class PipelineCompletedEvent < BaseEvent
    def listeners
      [
        # TODO: i'm unsure on what naming convention to use here yet.
        # - It's possible to define a listener that can handle multiple events.
        #   In this case a listener having a generic name from the domain it
        #   belongs to is fine.
        # - It's possible to have listeners that can handle only a specific
        #   event. In this case it's fine to use the same name of the event but
        #   namespaced with the domain handling it.
        #
        # Here below different types of naming we could mix
        #
        # Internal listener that reacts on behalf of a domain model (PersistentRef)
        Ci::Listeners::PersistentRefListener,
        # External domain listener that handles only this event
        MergeRequest::PipelineCompletedListener,
        # Generic listener. This class can also handle any events it subscribes to
        ProjectAutoDevops
      ]
    end
  end
end
