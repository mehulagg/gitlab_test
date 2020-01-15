# frozen_string_literal: true

module Analytics
  module ValueStreamAnalytics
    class ConfigurationEntity < Grape::Entity
      include RequestAwareEntity

      expose :events, using: Analytics::ValueStreamAnalytics::EventEntity
      expose :stages, using: Analytics::ValueStreamAnalytics::StageEntity

      private

      def events
        Gitlab::Analytics::ValueStreamAnalytics::StageEvents.events
      end
    end
  end
end
