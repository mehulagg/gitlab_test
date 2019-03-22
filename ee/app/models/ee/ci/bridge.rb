# frozen_string_literal: true

module EE
  module Ci
    module Bridge
      extend ActiveSupport::Concern

      prepended do
        include ::Ci::Metadatable

        # rubocop:disable Cop/ActiveRecordSerialize
        serialize :options
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
    end
  end
end
