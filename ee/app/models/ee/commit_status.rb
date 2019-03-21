# frozen_string_literal: true
module EE
  module CommitStatus
    extend ActiveSupport::Concern

    EE_FAILURE_REASONS = {
      protected_environment_failure: 1_000
    }.freeze

    class_methods do
      extend ::Gitlab::Utils::Override

      override :processable_types
      def processable_types
        super + %w[Ci::Bridges::DownstreamBridge Ci::Bridges::UpstreamBridge]
      end
    end
  end
end
