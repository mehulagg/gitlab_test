# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class GroupStage < ApplicationRecord
      include Analytics::CycleAnalytics::Stage

      validates :group, presence: true
      belongs_to :group
      belongs_to :group_value_stream

      alias_attribute :parent, :group
      alias_attribute :parent_id, :group_id

      scope :by_group_value_stream, -> (group_value_stream) { where(group_value_stream_id: group_value_stream.id) }

      def self.relative_positioning_query_base(stage)
        where(group_id: stage.group_id)
      end

      def self.relative_positioning_parent_column
        :group_id
      end
    end
  end
end
