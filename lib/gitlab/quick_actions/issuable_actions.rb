# frozen_string_literal: true

module Gitlab
  module QuickActions
    module IssuableActions
      include Gitlab::QuickActions::Dsl

      SHRUG = '¯\\＿(ツ)＿/¯'
      TABLEFLIP = '(╯°□°)╯︵ ┻━┻'

      types Issuable

      # Issue, MergeRequest, Epic: quick actions definitions
      command :close do
        desc do
          _('Close this %{quick_action_target}') % format_params
        end
        explanation do
          _('Closes this %{quick_action_target}.') % format_params
        end
        execution_message do
          _('Closed this %{quick_action_target}.') % format_params
        end
        condition do
          updateable? && quick_action_target.open?
        end
        action do
          update(state_event: 'close')
        end
      end

      command :reopen do
        desc do
          _('Reopen this %{quick_action_target}') % format_params
        end
        explanation do
          _('Reopens this %{quick_action_target}.') % format_params
        end
        execution_message do
          _('Reopened this %{quick_action_target}.') % format_params
        end
        condition do
          updateable? && quick_action_target.closed?
        end
        action do
          update(state_event: 'reopen')
        end
      end

      command :title do
        desc _('Change title')
        explanation do |title_param|
          _('Changes the title to "%{title_param}".') % { title_param: title_param }
        end
        execution_message do |title_param|
          _('Changed the title to "%{title_param}".') % { title_param: title_param }
        end
        params '<New title>'
        condition { updateable? }
        action do |title_param|
          update(title: title_param)
        end
      end

      command :label do
        desc _('Add label(s)')
        explanation do |labels_param|
          labels = find_label_references(labels_param)

          if labels.any?
            _("Adds %{labels} %{label_text}.") %
              { labels: labels.join(' '), label_text: 'label'.pluralize(labels.count) }
          end
        end
        params '~label1 ~"label 2"'
        condition do
          parent &&
            current_user.can?(:"admin_#{ability_name}", parent) &&
            find_labels.any?
        end
        action do |labels_param|
          run_label_command(labels: find_labels(labels_param), command: :label, updates_key: :add_label_ids)
        end
      end

      command :unlabel, :remove_label do
        desc _('Remove all or specific label(s)')
        explanation do |labels_param = nil|
          label_references = labels_param.present? ? find_label_references(labels_param) : []
          if label_references.any?
            _("Removes %{label_references} %{label_text}.") %
              { label_references: label_references.join(' '), label_text: 'label'.pluralize(label_references.count) }
          else
            _('Removes all labels.')
          end
        end
        params '~label1 ~"label 2"'
        condition do
          quick_action_target.persisted? &&
            quick_action_target.labels.any? &&
            current_user.can?(:"admin_#{ability_name}", parent)
        end
        action do |labels_param = nil|
          if labels_param.present?
            labels = find_labels(labels_param)
            label_ids = labels.map(&:id)
            label_references = labels_to_reference(labels, :name)

            if label_ids.any?
              modify(:remove_label_ids) do |current|
                Array.wrap(current).concat(label_ids).uniq
              end
            end
          else
            update(label_ids: [])
            label_references = []
          end

          info remove_label_message(label_references)
        end
      end

      command :relabel do
        desc _('Replace all label(s)')
        explanation do |labels_param|
          labels = find_label_references(labels_param)
          "Replaces all labels with #{labels.join(' ')} #{'label'.pluralize(labels.count)}." if labels.any?
        end
        params '~label1 ~"label 2"'
        condition do
          quick_action_target.persisted? &&
            quick_action_target.labels.any? &&
            current_user.can?(:"admin_#{ability_name}", parent)
        end
        action do |labels_param|
          run_label_command(labels: find_labels(labels_param), command: :relabel, updates_key: :label_ids)
        end
      end

      command :todo do
        desc _('Add a To Do')
        explanation _('Adds a To Do.')
        execution_message _('Added a To Do.')
        condition do
          quick_action_target.persisted? &&
            !TodoService.new.todo_exist?(quick_action_target, current_user)
        end
        action do
          update(todo_event: 'add')
        end
      end

      command :done do
        desc _('Mark To Do as done')
        explanation _('Marks To Do as done.')
        execution_message _('Marked To Do as done.')
        condition do
          quick_action_target.persisted? &&
            TodoService.new.todo_exist?(quick_action_target, current_user)
        end
        action do
          update(todo_event: 'done')
        end
      end

      command :subscribe do
        desc _('Subscribe')
        explanation do
          _('Subscribes to this %{quick_action_target}.') %
            { quick_action_target: quick_action_target.to_ability_name.humanize(capitalize: false) }
        end
        execution_message do
          _('Subscribed to this %{quick_action_target}.') %
            { quick_action_target: quick_action_target.to_ability_name.humanize(capitalize: false) }
        end
        condition do
          quick_action_target.persisted? &&
            !quick_action_target.subscribed?(current_user, project)
        end
        action do
          update(subscription_event: 'subscribe')
        end
      end

      command :unsubscribe do
        desc _('Unsubscribe')
        explanation do
          _('Unsubscribes from this %{quick_action_target}.') % format_params
        end
        execution_message do
          _('Unsubscribed from this %{quick_action_target}.') % format_params
        end
        condition do
          quick_action_target.persisted? &&
            quick_action_target.subscribed?(current_user, project)
        end
        action do
          update(subscription_event: 'unsubscribe')
        end
      end

      command :award do
        desc _('Toggle emoji award')
        explanation do |name|
          _("Toggles :%{name}: emoji award.") % { name: name } if name
        end
        execution_message do |name|
          _("Toggled :%{name}: emoji award.") % { name: name } if name
        end
        params ':emoji:'
        condition do
          quick_action_target.persisted? &&
            quick_action_target.user_can_award?(current_user)
        end
        parse_params do |emoji_param|
          match = emoji_param.match(Banzai::Filter::EmojiFilter.emoji_pattern)
          match[1] if match
        end
        action do |name|
          update(emoji_award: name) if name
        end
      end

      substitution :shrug do
        desc _("Append the comment with %{shrug}") % { shrug: SHRUG }
        params '<Comment>'
        action do |comment|
          "#{comment} #{SHRUG}"
        end
      end

      substitution :tableflip do
        desc _("Append the comment with %{tableflip}") % { tableflip: TABLEFLIP }
        params '<Comment>'
        action do |comment|
          "#{comment} #{TABLEFLIP}"
        end
      end

      helpers do
        def ability_name
          quick_action_target.to_ability_name
        end

        def format_params
          { quick_action_target: ability_name.humanize(capitalize: false) }
        end

        def updateable?
          quick_action_target.persisted? && can_ability?(:update)
        end

        def run_label_command(labels:, command:, updates_key:)
          return if labels.empty?

          modify(updates_key) do |current|
            Array.wrap(current).concat(labels.map(&:id)).uniq
          end

          label_references = labels_to_reference(labels, :name)
          msg = case command
                when :relabel
                  _('Replaced all labels with %{label_references} %{label_text}.') %
                    {
                    label_references: label_references.join(' '),
                    label_text: 'label'.pluralize(label_references.count)
                  }
                when :label
                  _('Added %{label_references} %{label_text}.') %
                    {
                    label_references: label_references.join(' '),
                    label_text: 'label'.pluralize(labels.count)
                  }
                end

          info(msg)
        end

        def remove_label_message(label_references)
          if label_references.any?
            _("Removed %{label_references} %{label_text}.") %
              { label_references: label_references.join(' '), label_text: 'label'.pluralize(label_references.count) }
          else
            _('Removed all labels.')
          end
        end
      end
    end
  end
end
