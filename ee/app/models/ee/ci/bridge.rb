# frozen_string_literal: true

module EE
  module Ci
    module Bridge
      extend ActiveSupport::Concern

      prepended do
        include ::Ci::Metadatable

        # rubocop:disable Cop/ActiveRecordSerialize
        serialize :options
        serialize :yaml_variables, ::Gitlab::Serializer::Ci::Variables
        # rubocop:enable Cop/ActiveRecordSerialize

        def self.fabricate(attributes)
          hash_attributes = attributes.to_h

          if hash_attributes.dig(:options, :trigger).present?
            ::Ci::Bridges::DownstreamBridge.new(attributes)
          elsif hash_attributes.dig(:options, :triggered_by).present?
            ::Ci::Bridges::UpstreamBridge.new(attributes)
          else
            super(attributes)
          end
        end
      end

      def target_user
        self.user
      end

      def target_ref
        options&.dig(:trigger, :branch)
      end

      def downstream_variables
        yaml_variables.to_a.map { |hash| hash.except(:public) }
      end
    end
  end
end
