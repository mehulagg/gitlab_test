# frozen_string_literal: true

module Gitlab
  module QuickActions
    module IssueActions
      include Gitlab::QuickActions::DslNew

      types Issue

      command :due do
        desc _('Set due date')
        params '<in 2 days | this Friday | December 31st>'
        explanation do |due_date|
          format_due_date(_("Sets the due date to %{due_date}."), due_date)
        end
        execution_message do |due_date|
          format_due_date(_("Set the due date to %{due_date}."), due_date)
        end
        condition do
          due_date? && can_ability?(:admin, subject: project)
        end
        parse_params do |due_date_param|
          Chronic.parse(due_date_param).try(:to_date)
        end
        action do |due_date|
          if due_date
            update(due_date: due_date)
          else
            warn _('Failed to set due date because the date format is invalid.')
          end
        end
      end

      command :remove_due_date do
        desc _('Remove due date')
        explanation _('Removes the due date.')
        execution_message _('Removed the due date.')
        condition do
          quick_action_target.persisted? &&
            due_date? &&
            quick_action_target.due_date? &&
            can_ability?(:admin, subject: project)
        end
        action { update(due_date: nil) }
      end

      command :board_move do
        desc _('Move issue from one column of the board to another')
        explanation do |target_list_name|
          label = find_label_references(target_list_name).first
          _("Moves issue to %{label} column in the board.") % { label: label } if label
        end
        params '~"Target column"'
        condition do
          can_ability?(:update) && quick_action_target.project.boards.count == 1
        end
        action do |target_list_name|
          labels = find_labels(target_list_name)
          label_ids = labels.map(&:id)

          if label_ids.size > 1
            warn _('Failed to move this issue because only a single label can be provided.')
          elsif !Label.on_project_board?(quick_action_target.project_id, label_ids.first)
            warn _('Failed to move this issue because label was not found.')
          else
            label_id = label_ids.first

            update(remove_label_ids: remove_label_ids(label_id), add_label_ids: [label_id])

            info _("Moved issue to %{label} column in the board.") % { label: labels_to_reference(labels).first }
          end
        end

        helpers do
          # rubocop:disable CodeReuse/ActiveRecord
          def remove_label_ids(label_to_keep)
            quick_action_target.labels
              .on_project_boards(quick_action_target.project_id)
              .where.not(id: label_to_keep)
              .pluck(:id)
          end
          # rubocop:enable CodeReuse/ActiveRecord
        end
      end

      command :duplicate do
        desc _('Mark this issue as a duplicate of another issue')
        explanation do |duplicate_reference|
          _("Marks this issue as a duplicate of %{duplicate_reference}.") % { duplicate_reference: duplicate_reference }
        end
        params '#issue'
        condition do
          quick_action_target.persisted? && can_ability?(:update)
        end
        action do |duplicate_param|
          canonical_issue = extract_references(duplicate_param, :issue).first

          if canonical_issue.present?
            update(canonical_issue_id: canonical_issue.id)

            info _("Marked this issue as a duplicate of %{duplicate_param}.") % { duplicate_param: duplicate_param }
          else
            warn _('Failed to mark this issue as a duplicate because referenced issue was not found.')
          end
        end
      end

      command :move do
        desc _('Move this issue to another project.')
        explanation do |path_to_project|
          _("Moves this issue to %{path_to_project}.") % { path_to_project: path_to_project }
        end
        params 'path/to/project'
        condition do
          quick_action_target.persisted? && can_ability?(:admin)
        end
        action do |target_project_path|
          target_project = Project.find_by_full_path(target_project_path)

          if target_project.present?
            update(target_project: target_project)

            info _("Moved this issue to %{path_to_project}.") % { path_to_project: target_project_path }
          else
            warn _("Failed to move this issue because target project doesn't exist.")
          end
        end
      end

      command :confidential do
        desc _('Make issue confidential')
        explanation do
          _('Makes this issue confidential.')
        end
        execution_message do
          _('Made this issue confidential.')
        end
        condition do
          !quick_action_target.confidential? && can_ability?(:admin)
        end
        action do
          update(confidential: true)
        end
      end

      command :create_merge_request do
        desc _('Create a merge request')
        explanation do |branch_name = nil|
          if branch_name
            _("Creates branch '%{branch_name}' and a merge request to resolve this issue.") % { branch_name: branch_name }
          else
            _('Creates a branch and a merge request to resolve this issue.')
          end
        end
        execution_message do |branch_name = nil|
          if branch_name
            _("Created branch '%{branch_name}' and a merge request to resolve this issue.") % { branch_name: branch_name }
          else
            _('Created a branch and a merge request to resolve this issue.')
          end
        end
        params "<branch name>"
        condition do
          current_user.can?(:create_merge_request_in, project) && current_user.can?(:push_code, project)
        end
        action do |branch_name = nil|
          update(create_merge_request: { branch_name: branch_name,
                                         issue_iid: quick_action_target.iid })
        end
      end

      command :zoom do
        desc _('Add Zoom meeting')
        explanation _('Adds a Zoom meeting')
        params '<Zoom URL>'
        condition { zoom_link_service.can_add_link? }
        parse_params do |link|
          zoom_link_service.parse_link(link)
        end
        action do |link|
          result = zoom_link_service.add_link(link)

          if result.success?
            update(result.payload) if result.payload
            info result.message
          else
            warn result.message
          end
        end
      end

      command :remove_zoom do
        desc _('Remove Zoom meeting')
        explanation _('Remove Zoom meeting')
        execution_message _('Zoom meeting removed')
        condition { zoom_link_service.can_remove_link? }
        action do
          result = zoom_link_service.remove_link
          if result.success?
            info result.message
          else
            warn result.message
          end
        end
      end

      helpers do
        def zoom_link_service
          @zoom_link_service ||= Issues::ZoomLinkService.new(quick_action_target, current_user)
        end

        def due_date?
          quick_action_target.respond_to?(:due_date)
        end

        def format_due_date(template, due_date)
          return unless due_date

          template % { due_date: due_date.strftime('%b %-d, %Y') }
        end
      end
    end
  end
end
