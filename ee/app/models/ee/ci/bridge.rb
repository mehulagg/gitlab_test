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
          ::Ci::Bridges::Downstream.new(attributes)
        end
      end

      def target_project_path
        options&.dig(:trigger, :project)
      end

      def target_ref
        options&.dig(:trigger, :branch)
      end

      def target_user
        self.user
      end
    end
  end
end
