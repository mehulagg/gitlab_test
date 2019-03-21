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
