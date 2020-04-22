# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module EpicActions
        include ::Gitlab::QuickActions::DslNew

        types Epic

        command :child_epic, :add_child_epic do
          desc _('Add child epic to an epic')
          explanation do
            epic_message(_("Adds %{epic_ref} as child epic."), child_epic)
          end
          condition { action_allowed? }
          params '<&epic | group&epic | Epic URL>'
          parse_params(as: :child_epic) { |param| extract_epic(param) }
          action do
            if problem = precheck
              warn child_error_message(problem)
            else
              result = create_link(target_epic, child_epic)

              if result[:status] == :error
                warn result[:message]
              else
                info epic_message(_("Added %{epic_ref} as a child epic."), child_epic)
              end
            end
          end

          helpers do
            def precheck
              return :not_present unless child_epic.present?
              return :already_related if epics_related?(child_epic)
              return :no_permission unless current_user.can?(:read_epic, child_epic)
            end
          end
        end

        command :remove_child_epic do
          desc _('Remove child epic from an epic')
          explanation do
            epic_message(_("Removes %{epic_ref} from child epics."), child_epic)
          end
          condition { action_allowed? }
          params '<&epic | group&epic | Epic URL>'
          parse_params(as: :child_epic) { |param| extract_epic(param) }
          action do
            if child_epic && quick_action_target.child?(child_epic.id)
              EpicLinks::DestroyService.new(child_epic, current_user).execute

              info epic_message(_("Removed %{epic_ref} from child epics."), child_epic)
            else
              warn _("Child epic does not exist.")
            end
          end
        end

        command :parent_epic, :set_parent_epic do
          desc _('Set parent epic to an epic')
          explanation do
            epic_message(_("Sets %{epic_ref} as parent epic."), parent_epic)
          end
          condition { action_allowed? }
          params '<&epic | group&epic | Epic URL>'
          parse_params(as: :parent_epic) { |param| extract_epic(param) }
          action do
            if problem = precheck
              warn parent_error_message(problem)
            else
              create_link(parent_epic, target_epic)
              info epic_message(_("Set %{epic_ref} as the parent epic."), parent_epic)
            end
          end

          helpers do
            def precheck
              return :not_present unless parent_epic.present?
              return :already_related if epics_related?(parent_epic)
              return :no_permission unless current_user.can?(:read_epic, parent_epic)
            end
          end
        end

        command :remove_parent_epic do
          desc _('Remove parent epic from an epic')
          explanation do
            message(_('Removes parent epic %{epic_ref}.'))
          end
          condition { action_allowed? }
          action do
            if parent_epic
              EpicLinks::DestroyService.new(quick_action_target, current_user).execute

              info message(_('Removed parent epic %{epic_ref}.'))
            else
              warn _("Parent epic is not present.")
            end
          end

          helpers do
            def parent_epic
              @parent ||= quick_action_target.parent
            end

            def message(fmt)
              epic_message(fmt, parent_epic)
            end
          end
        end

        helpers do
          def extract_epic(params)
            return if params.nil?

            extract_references(params, :epic).first
          end

          def action_allowed?
            quick_action_target.group&.feature_available?(:subepics) && can_ability?(:admin)
          end

          def epics_related?(epic)
            epic.child?(target_epic.id) || target_epic.child?(epic.id)
          end

          def target_epic
            quick_action_target
          end

          def create_link(parent, child)
            EpicLinks::CreateService
              .new(parent, current_user, { target_issuable: child })
              .execute
          end

          def epic_message(fmt, epic)
            fmt % { epic_ref: epic.to_reference(target_epic) } if epic
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
