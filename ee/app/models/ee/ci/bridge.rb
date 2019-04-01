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
          ::Ci::Bridges::Downstream.new(attributes)
        end
      end

      def target_project_path
        raise NotImplementedError
      end

      def target_ref
        raise NotImplementedError
      end

      def target_user
        self.user
      end
    end
  end
end
