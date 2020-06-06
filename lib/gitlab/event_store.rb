# frozen_string_literal: true

# Gitlab::EventStore is a simple pub-sub mechanism that let you publish
# domain events and use Sidekiq workers as event handlers.
#
# It can be used to decouple domains from different bounded contexts
# by publishing domain events and let any interested parties subscribe
# to them.
#
# In `config/initializers/event_store.rb` define all event subscriptions
# using:
#
#   Gitlab::EventStore.instance.tap do |store|
#     store.subscribe(DomainA::SomeWorker, to: DomainB::SomeEvent)
#   end
#
# Unless you are subscribing to an existing event, an event can be
# defined as:
#
#   DomainB::SomeEvent = Class.new(Gitlab::EventStore::Event)
#
# and published as:
#
#   event = DomainB::SomeEvent.new(data: { any: 'data', you: 'like' })
#   Gitlab::EventStore.instance.publish(event)
#
# It's also possible to subscribe to a subset of events matching a condition:
#
#   store.subscribe(DomainA::SomeWorker, to: DomainB::SomeEvent), if: ->(event) { event.data == :some_value }

module Gitlab
  class EventStore
    Event = Struct.new(:data, keyword_init: true)

    Subscription = Struct.new(:worker, :condition) do
      def consume_event(event)
        return unless condition_met?(event)

        worker.perform_async(event.class.name, event.data)
      rescue => e
        Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
      end

      private

      def condition_met?(event)
        return true unless condition

        condition.call(event)
      end
    end

    Error = Class.new(StandardError)
    InvalidEvent = Class.new(Error)
    InvalidSubscriber = Class.new(Error)

    include Singleton

    attr_reader :subscriptions

    def self.subscribe(*args)
      instance.subscribe(*args)
    end

    def self.publish(*args)
      instance.publish(*args)
    end

    def initialize
      reset!
    end

    def subscribe(worker, to:, if: nil)
      condition = binding.local_variable_get('if')

      Array(to).each do |event|
        validate_subscription!(worker, event)
        subscriptions[event] << Gitlab::EventStore::Subscription.new(worker, condition)
      end
    end

    def publish(event)
      raise InvalidEvent, "Event being published is not an instance of #{Event}: got #{event.inspect}" unless event.is_a?(Event)

      subscriptions[event.class].each do |subscription|
        subscription.consume_event(event)
      end
    end

    # clears all subscriptions. Should only be used for testing.
    def reset!
      @subscriptions = Hash.new { |h, k| h[k] = [] }
    end

    private

    def validate_subscription!(subscriber, event_class)
      raise InvalidEvent, "Event being subscribed to is not a subclass of #{Event}: got #{event_class}" unless event_class < Event
      raise InvalidSubscriber, "Subscriber is not an #{ApplicationWorker}: got #{subscriber}" unless subscriber.respond_to?(:perform_async)
    end
  end
end
