module Flipper
  module Adapters
    # Public: Adapter that wraps another adapter with the ability to cascadingly executes
    # adapter calls in multiple persistent layers.
    #
    class MultiPersistentLayer
      include ::Flipper::Adapter

      # Public: The name of the adapter.
      attr_reader :name

      # Public
      def initialize(*adapters)
        @adapters = adapters
        @name = :multi_persistent_layer
      end

      # Public
      def features
        with_adapters do |adapter|
          adapter.features
        end
      end

      # Public
      def add(feature)
        with_adapters do |adapter|
          adapter.add(feature)
        end
      end

      ## Public
      def remove(feature)
        with_adapters do |adapter|
          adapter.remove(feature)
        end
      end

      ## Public
      def clear(feature)
        with_adapters do |adapter|
          adapter.clear(feature)
        end
      end

      ## Public
      def get(feature)
        with_adapters do |adapter|
          adapter.get(feature)
        end
      end

      def get_multi(features)
        with_adapters do |adapter|
          adapter.get_multi(feature)
        end
      end

      def get_all
        with_adapters do |adapter|
          adapter.get_all(feature)
        end
      end

      ## Public
      def enable(feature, gate, thing)
        with_adapters do |adapter|
          adapter.enable(feature, gate, thing)
        end
      end

      ## Public
      def disable(feature, gate, thing)
        with_adapters do |adapter|
          adapter.disable(feature, gate, thing)
        end
      end

      private

      def with_adapters
        @adapters.each do |adapter|
          break yield adapter
        rescue NotImplementedError, EmptyDataError
          # no-op. Evaluate the next adapter
        end
      end
    end
  end
end
