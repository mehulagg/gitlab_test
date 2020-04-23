# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module IssueAndMergeRequestActions
        include ::Gitlab::QuickActions::DslNew

        types Issue, MergeRequest

        command :reassign do
          desc _('Change assignee(s)')
          explanation _('Change assignee(s).')
          execution_message _('Changed assignee(s).')
          params '@user1 @user2'
          condition do
            quick_action_target.allows_multiple_assignees? &&
              quick_action_target.persisted? &&
              can_ability?(:admin, subject: project)
          end
          action do |reassign_param|
            update(assignee_ids: extract_users(reassign_param).map(&:id))
          end
        end

        command :weight do
          desc _('Set weight')
          explanation do
            _("Sets weight to %{weight}.") % { weight: weight } if weight
          end
          params "0, 1, 2, …"
          condition do
            quick_action_target.supports_weight? && can_ability?(:admin)
          end
          parse_params(as: :weight) do |param|
            param.to_i if param.to_i >= 0
          end
          action do
            if weight
              update(weight: weight)
              info _("Set weight to %{weight}.") % { weight: weight }
            else
              warn _('Numeric weight not provided')
            end
          end
        end

        command :clear_weight do
          desc _('Clear weight')
          explanation _('Clears weight.')
          execution_message _('Cleared weight.')
          condition do
            quick_action_target.persisted? &&
              quick_action_target.supports_weight? &&
              quick_action_target.weight? &&
              can_ability?(:admin)
          end
          action { update(weight: nil) }
        end
      end
    end
  end
end
