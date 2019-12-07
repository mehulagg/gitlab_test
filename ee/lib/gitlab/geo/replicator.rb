# frozen_string_literal: true

module Gitlab
  module Geo
    class Replicator
      # Declare supported event
      #
      # @example Declaring support for :update and :delete events
      #   class MyReplicator < Gitlab::Geo::Replicator
      #     event :update
      #     event :delete
      #   end
      #
      # @param [Symbol] event_name
      def self.event(event_name)
        @events ||= []
        @events << event_name.to_sym
      end
      private_class_method :event

      # List supported events
      #
      # @return [Array<Symbol>] with list of events
      def self.supported_events
        @events.dup
      end

      # Check if the replicator supports a specific event
      #
      # @param [Boolean] event_name
      def self.event_supported?(event_name)
        @events.include?(event_name.to_sym)
      end

      attr_reader :model

      def initialize(model: nil)
        @model = model
      end

      # Publish an event, using current defined context and additional data
      #
      # @param [Symbol] event_name
      # @param [Hash] params additional context data to help publish the event
      def publish(event_name, **params)
        raise ArgumentError, "Unsupported event: '#{event_name}'" unless self.class.event_supported?(event_name)

        publish_method = "publish_#{event_name}".to_sym
        raise NotImplementedError, "Publish method not implemented: '#{publish_method}'" unless instance_method_defined?(publish_method)

        # Inject model based on included class
        if model
          params[:model] = model
        end

        send(publish_method, **params) # rubocop:disable GitlabSecurity/PublicSend
      end

      # Process an event, using the published contextual data
      #
      # This method is called by the GeoLogCursor when reading the event from the queue
      #
      # @param [Symbol] event_name
      # @param [Hash] params contextual data published with the event
      def process(event_name, **params)
        raise ArgumentError, "Unsupported event: '#{event_name}'" unless self.class.event_supported?(event_name)

        process_method = "process_#{event_name}".to_sym
        raise NotImplementedError, "Process method not implemented: '#{process_method}'" unless instance_method_defined?(process_method)

        # Inject model based on included class
        if model
          params[:model] = model
        end

        send(process_method, **params) # rubocop:disable GitlabSecurity/PublicSend
      end

      def registry
        raise NotImplementedError
      end

      private

      # Checks if method is implemented by current class (ignoring inherited methods)
      #
      # @param [Symbol] method_name
      # @return [Boolean] whether method is implemented
      def instance_method_defined?(method_name)
        self.class.instance_methods(false).include?(method_name)
      end
    end
  end
end
