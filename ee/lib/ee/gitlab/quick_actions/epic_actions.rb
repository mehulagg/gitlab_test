# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module EpicActions
        include ::Gitlab::QuickActions::Dsl

        ExecutionError = Class.new(StandardError)

        desc _('Add child epic to an epic')
        explanation do |epic_param|
          child_epic = extract_epic(epic_param)

          _("Adds %{epic_ref} as child epic.") % { epic_ref: child_epic.to_reference(quick_action_target) } if child_epic
        end
        types Epic
        condition { action_allowed? }
        params '<&epic | group&epic | Epic URL>'
        command :child_epic do |epic_param|
          child_epic = extract_epic(epic_param)

          info add_child_epic(quick_action_target, child_epic)
        rescue ExecutionError => e
          warn e.message
        end

        desc _('Remove child epic from an epic')
        explanation do |epic_param|
          child_epic = extract_epic(epic_param)

          _("Removes %{epic_ref} from child epics.") % { epic_ref: child_epic.to_reference(quick_action_target) } if child_epic
        end
        types Epic
        condition { action_allowed? }
        params '<&epic | group&epic | Epic URL>'
        command :remove_child_epic do |epic_param|
          child_epic = extract_epic(epic_param)

          if child_epic && quick_action_target.child?(child_epic.id)
            EpicLinks::DestroyService.new(child_epic, current_user).execute

            info _("Removed %{epic_ref} from child epics.") % { epic_ref: child_epic.to_reference(quick_action_target) }
          else
            warn _("Child epic does not exist.")
          end
        end

        desc _('Set parent epic to an epic')
        explanation do |epic_param|
          parent_epic = extract_epic(epic_param)

          _("Sets %{epic_ref} as parent epic.") % { epic_ref: parent_epic.to_reference(quick_action_target) } if parent_epic
        end
        types Epic
        condition { action_allowed? }
        params '<&epic | group&epic | Epic URL>'
        command :parent_epic do |epic_param|
          parent_epic = extract_epic(epic_param)

          info set_parent_epic(quick_action_target, parent_epic)
        rescue ExecutionError => e
          warn e.message
        end

        desc _('Remove parent epic from an epic')
        explanation do
          parent_epic = quick_action_target.parent

          _('Removes parent epic %{epic_ref}.') % { epic_ref: parent_epic.to_reference(quick_action_target) } if parent_epic
        end
        types Epic
        condition { action_allowed? }
        command :remove_parent_epic do
          parent_epic = quick_action_target.parent

          if parent_epic
            EpicLinks::DestroyService.new(quick_action_target, current_user).execute

            info _('Removed parent epic %{epic_ref}.') % { epic_ref: parent_epic.to_reference(quick_action_target) }
          else
            warn _("Parent epic is not present.")
          end
        end

        helpers do
          def extract_epic(params)
            return if params.nil?

            extract_references(params, :epic).first
          end

          def action_allowed?
            quick_action_target.group&.feature_available?(:subepics) &&
              current_user.can?(:"admin_#{quick_action_target.to_ability_name}", quick_action_target)
          end

          def epics_related?(epic, target_epic)
            epic.child?(target_epic.id) || target_epic.child?(epic.id)
          end

          def add_child_epic(target_epic, child_epic)
            raise ExecutionError, child_error_message(:not_present) unless child_epic.present?
            raise ExecutionError, child_error_message(:already_related) if epics_related?(child_epic, target_epic)
            raise ExecutionError, child_error_message(:no_permission) unless current_user.can?(:read_epic, child_epic)

            r = EpicLinks::CreateService.new(target_epic, current_user, { target_issuable: child_epic }).execute
            raise ExecutionError, r[:message] if r[:status] == :error

            _("Added %{epic_ref} as a child epic.") % { epic_ref: child_epic.to_reference(target_epic) }
          end

          def set_parent_epic(target_epic, parent_epic)
            raise ExecutionError, parent_error_message(:not_present) unless parent_epic.present?
            raise ExecutionError, parent_error_message(:already_related) if epics_related?(parent_epic, target_epic)
            raise ExecutionError, parent_error_message(:no_permission) unless current_user.can?(:read_epic, parent_epic)

            EpicLinks::CreateService.new(parent_epic, current_user, { target_issuable: target_epic }).execute

            _("Set %{epic_ref} as the parent epic.") % { epic_ref: parent_epic.to_reference(target_epic) }
          end

          def parent_error_message(reason)
            case reason
            when :not_present
              _("Parent epic doesn't exist.")
            when :already_related
              _("Given epic is already related to this epic.")
            when :no_permission
              _("You don't have sufficient permission to perform this action.")
            end
          end

          def child_error_message(reason)
            case reason
            when :not_present
              _("Child epic doesn't exist.")
            when :already_related
              _("Given epic is already related to this epic.")
            when :no_permission
              _("You don't have sufficient permission to perform this action.")
            end
          end
        end
      end
    end
  end
end
