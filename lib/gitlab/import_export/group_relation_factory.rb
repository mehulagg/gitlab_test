# frozen_string_literal: true

module Gitlab
  module ImportExport
    class GroupRelationFactory < BaseRelationFactory
      OVERRIDES = {
        labels:     :group_labels,
        priorities: :label_priorities,
        label:      :group_label,
        parent:     :epic
      }.freeze

      EXISTING_OBJECT_CHECK = %i[
        epic
        epics
        milestone
        milestones
        label
        labels
        group_label
        group_labels
      ].freeze

      private

      def setup_models
        case @relation_name
        when :notes then setup_note
        end

        update_group_references
      end

      def update_group_references
        return unless self.class.existing_object_check.include?(@relation_name)
        return unless @relation_hash['group_id']

        @relation_hash['group_id'] = @importable.id
      end
    end
  end
end
