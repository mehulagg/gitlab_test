# frozen_string_literal: true

module Gitlab
  module QuickActions
    module IssueAndMergeRequestActions
      include Gitlab::QuickActions::Dsl

      types Issue, MergeRequest

      # Issue, MergeRequest: quick actions definitions
      command :assign do
        desc _('Assign')
        explanation do |users|
          message(_('Assigns %{assignee_users_sentence}.'), users)
        end
        execution_message do |users = nil|
          if users.blank?
            warn _("Failed to assign a user because no user was found.")
          else
            message(_('Assigned %{assignee_users_sentence}.'), users)
          end
        end
        params { multi? ? '@user1 @user2' : '@user' }
        condition { can_ability?(:admin, subject: project) }
        parse_params do |assignee_param|
          users = extract_users(assignee_param)

          multi? ? users : users&.take(1)
        end
        action do |users|
          next if users.empty?

          ids = users.map(&:id)

          if multi?
            modify(:assignee_ids) do |current|
              current ||= quick_action_target.assignees.map(&:id)
              current | ids
            end
          else
            update(assignee_ids: ids)
          end
        end

        helpers do
          def multi?
            quick_action_target.allows_multiple_assignees?
          end

          def message(template, users)
            template % { assignee_users_sentence: assignee_users_sentence(users) }
          end
        end
      end

      command :unassign do
        desc { multi? ? _('Remove all or specific assignee(s)') : _('Remove assignee') }
        params { multi? ? '@user1 @user2' : '' }
        explanation do |users = nil|
          assignees = assignees_for_removal(users)
          _("Removes %{assignee_text} %{assignee_references}.") %
            { assignee_text: 'assignee'.pluralize(assignees.size), assignee_references: assignees.map(&:to_reference).to_sentence }
        end
        execution_message do |users = nil|
          assignees = assignees_for_removal(users)
          _("Removed %{assignee_text} %{assignee_references}.") %
            { assignee_text: 'assignee'.pluralize(assignees.size), assignee_references: assignees.map(&:to_reference).to_sentence }
        end
        condition do
          quick_action_target.persisted? &&
            quick_action_target.assignees.any? &&
            can_ability?(:admin, subject: project)
        end
        parse_params do |unassign_param|
          # When multiple users are assigned, all will be unassigned if multiple assignees are no longer allowed
          extract_users(unassign_param) if multi?
        end
        action do |users = nil|
          if multi? && users&.any?
            modify(:assignee_ids) do |current|
              current ||= quick_action_target.assignees.map(&:id)
              current - users.map(&:id)
            end
          else
            update(assignee_ids: [])
          end
        end

        helpers do
          def multi?
            quick_action_target.allows_multiple_assignees?
          end
        end
      end

      command :milestone do
        desc _('Set milestone')
        explanation do |milestone|
          _("Sets the milestone to %{milestone_reference}.") % { milestone_reference: milestone.to_reference } if milestone
        end
        execution_message do |milestone|
          _("Set the milestone to %{milestone_reference}.") % { milestone_reference: milestone.to_reference } if milestone
        end
        params '%"milestone"'
        condition do
          can_ability?(:admin, subject: project) && find_milestones(project, state: 'active').any?
        end
        parse_params do |milestone_param|
          extract_references(milestone_param, :milestone).first ||
            find_milestones(project, title: milestone_param.strip).first
        end
        action do |milestone|
          if milestone
            update(milestone_id: milestone.id)
          else
            warn _('Could not find milestone')
          end
        end
      end

      command :remove_milestone do
        desc _('Remove milestone')
        explanation { message(_("Removes %{milestone_reference} milestone.")) }
        execution_message { message(_("Removed %{milestone_reference} milestone.")) }
        condition do
          quick_action_target.persisted? && quick_action_target.milestone_id? &&
            can_ability?(:admin, subject: project)
        end
        action do
          update(milestone_id: nil)
        end

        helpers do
          def message(fmt)
            fmt % { milestone_reference: quick_action_target.milestone.to_reference(format: :name) }
          end
        end
      end

      command :copy_metadata do
        desc _('Copy labels and milestone from other issue or merge request in this project')
        explanation do |source_issuable|
          _("Copy labels and milestone from %{source_issuable_reference}.") % { source_issuable_reference: source_issuable.to_reference }
        end
        params '#issue | !merge_request'
        condition do
          can_ability?(:admin)
        end
        parse_params do |issuable_param|
          extract_references(issuable_param, :issue).first ||
            extract_references(issuable_param, :merge_request).first
        end
        action do |source_issuable|
          if can_copy_metadata?(source_issuable)
            update(add_label_ids: source_issuable.labels.map(&:id))
            update(milestone_id: source_issuable.milestone.id) if source_issuable.milestone

            info _("Copied labels and milestone from %{source_issuable_reference}.") % { source_issuable_reference: source_issuable.to_reference }
          end
        end
      end

      command :estimate do
        desc _('Set time estimate')
        explanation do |time_estimate|
          formatted_time_estimate = format_time_estimate(time_estimate)
          _("Sets time estimate to %{time_estimate}.") % { time_estimate: formatted_time_estimate } if formatted_time_estimate
        end
        execution_message do |time_estimate|
          formatted_time_estimate = format_time_estimate(time_estimate)
          _("Set time estimate to %{time_estimate}.") % { time_estimate: formatted_time_estimate } if formatted_time_estimate
        end
        params '<1w 3d 2h 14m>'
        condition do
          current_user.can?(:"admin_#{quick_action_target.to_ability_name}", project)
        end
        parse_params do |raw_duration|
          Gitlab::TimeTrackingFormatter.parse(raw_duration)
        end
        action do |time_estimate|
          update(time_estimate: time_estimate) if time_estimate
        end
      end

      command :spend do
        desc _('Add or subtract spent time')
        explanation do |time_spent, time_spent_date|
          spend_time_message(time_spent, time_spent_date, false)
        end
        execution_message do |time_spent, time_spent_date|
          spend_time_message(time_spent, time_spent_date, true)
        end

        params '<time(1h30m | -1h30m)> <date(YYYY-MM-DD)>'
        condition { can_ability?(:admin) }
        parse_params do |raw_time_date|
          Gitlab::QuickActions::SpendTimeAndDateSeparator.new(raw_time_date).execute
        end
        action do |time_spent, time_spent_date|
          if time_spent
            update(spend_time: {
              duration: time_spent,
              user_id: current_user.id,
              spent_at: time_spent_date
            })
          end
        end
      end

      command :remove_estimate do
        desc _('Remove time estimate')
        explanation _('Removes time estimate.')
        execution_message _('Removed time estimate.')
        condition do
          quick_action_target.persisted? && can_ability?(:admin, subject: project)
        end
        action do
          update(time_estimate: 0)
        end
      end

      command :remove_time_spent do
        desc _('Remove spent time')
        explanation _('Removes spent time.')
        execution_message _('Removed spent time.')
        condition do
          quick_action_target.persisted? && can_ability?(:admin, subject: project)
        end
        action do
          update(spend_time: { duration: :reset, user_id: current_user.id })
        end
      end

      command :lock do
        desc _("Lock the discussion")
        explanation _("Locks the discussion.")
        execution_message _("Locked the discussion.")
        condition do
          quick_action_target.persisted? && !quick_action_target.discussion_locked? && can_ability?(:admin)
        end
        action do
          update(discussion_locked: true)
        end
      end

      command :unlock do
        desc _("Unlock the discussion")
        explanation _("Unlocks the discussion.")
        execution_message _("Unlocked the discussion.")
        condition do
          quick_action_target.persisted? && quick_action_target.discussion_locked? && can_ability?(:admin)
        end
        action do
          update(discussion_locked: false)
        end
      end

      helpers do
        def assignee_users_sentence(users)
          if quick_action_target.allows_multiple_assignees?
            users
          else
            [users.first]
          end.map(&:to_reference).to_sentence
        end

        def assignees_for_removal(users)
          assignees = quick_action_target.assignees
          if users.present? && quick_action_target.allows_multiple_assignees?
            users
          else
            assignees
          end
        end

        def can_copy_metadata?(source_issuable)
          source_issuable.present? && source_issuable.project_id == quick_action_target.project_id
        end

        def format_time_estimate(time_estimate)
          Gitlab::TimeTrackingFormatter.output(time_estimate)
        end

        def spend_time_message(time_spent, time_spent_date, paste_tense)
          return unless time_spent

          if time_spent > 0
            verb = paste_tense ? _('Added') : _('Adds')
            value = time_spent
          else
            verb = paste_tense ? _('Subtracted') : _('Subtracts')
            value = -time_spent
          end

          _("%{verb} %{time_spent_value} spent time.") % { verb: verb, time_spent_value: format_time_estimate(value) }
        end
      end
    end
  end
end
