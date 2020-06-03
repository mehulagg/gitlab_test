require 'flipper'
require 'flipper/adapters/http'

# This is a restricted version of the official Http Adapter
module Flipper
  module Adapters
    class ReadonlyHttp < Flipper::Adapters::Http
      EmptyDataError = Class.new(StandardError)

      # Public
      def features
        super.tap do |result|
          raise EmptyDataError if result.empty?
        end
      end

      ## Public
      def get(feature)
        super.tap do |result|
          raise EmptyDataError if result.empty?
        end
      end

      def get_multi(features)
        super.tap do |result|
          raise EmptyDataError if result.empty?
        end
      end

      def get_all
        super.tap do |result|
          raise EmptyDataError if result.empty?
        end
      end

      def add(feature)
        raise NotImplementedError
      end

      def remove(feature)
        raise NotImplementedError
      end

      def enable(feature, gate, thing)
        raise NotImplementedError
      end

      def disable(feature, gate, thing)
        raise NotImplementedError
      end

      def clear(feature)
        raise NotImplementedError
      end
    end
  end
end
