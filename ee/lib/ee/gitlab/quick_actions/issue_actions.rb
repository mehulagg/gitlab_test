# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module IssueActions
        include ::Gitlab::QuickActions::DslNew

        types Issue

        command :epic do
          desc _('Add to epic')
          explanation _('Adds an issue to an epic.')
          condition do
            epics_available? && can_ability?(:admin)
          end
          params '<&epic | group&epic | Epic URL>'
          parse_params(as: :epic) { |params| extract_epic(params) }
          action do
            if epic && current_user.can?(:read_epic, epic)
              if issue.epic == epic
                warn(_('Issue %{issue_reference} has already been added to epic %{epic_reference}.') %
                  { issue_reference: issue.to_reference, epic_reference: epic.to_reference })
              else
                update(epic: epic)
                info _('Added an issue to an epic.')
              end
            else
              warn _("This epic does not exist or you don't have sufficient permission.")
            end
          end
        end

        command :remove_epic do
          desc _('Remove from epic')
          explanation _('Removes an issue from an epic.')
          execution_message _('Removed an issue from an epic.')
          condition do
            issue.persisted? && epics_available? && can_ability?(:admin)
          end
          action do
            update(epic: nil)
          end
        end

        command :promote do
          icon 'confidential'
          desc do
            if issue.confidential?
              promote_message_confidential
            else
              promote_message
            end
          end
          explanation { promote_message }
          warning { promote_message_confidential if quick_action_target.confidential? }
          condition do
            issue.persisted? &&
              !issue.promoted? &&
              current_user.can?(:admin_issue, project) &&
              current_user.can?(:create_epic, project.group)
          end
          action do
            update(promote_to_epic: true)

            msg = if issue.confidential?
                    _('Promoted confidential issue to a non-confidential epic. Information in this issue is no longer confidential as epics are public to group members.')
                  else
                    _('Promoted issue to an epic.')
                  end

            info(msg)
          end

          helpers do
            def promote_message
              _('Promote issue to an epic')
            end

            def promote_message_confidential
              _('Promote confidential issue to a non-confidential epic')
            end
          end
        end

        desc _('Set iteration')
        explanation do |iteration|
          _("Sets the iteration to %{iteration_reference}.") % { iteration_reference: iteration.to_reference } if iteration
        end
        execution_message do |iteration|
          _("Set the iteration to %{iteration_reference}.") % { iteration_reference: iteration.to_reference } if iteration
        end
        params '*iteration:"iteration"'
        types Issue
        condition do
          current_user.can?(:"admin_#{quick_action_target.to_ability_name}", project) &&
            quick_action_target.project.group&.feature_available?(:iterations) &&
            find_iterations(project, state: 'active').any?
        end
        parse_params do |iteration_param|
          extract_references(iteration_param, :iteration).first ||
            find_iterations(project, title: iteration_param.strip).first
        end
        command :iteration do |iteration|
          @updates[:iteration] = iteration if iteration
        end

        desc _('Remove iteration')
        explanation do
          _("Removes %{iteration_reference} iteration.") % { iteration_reference: quick_action_target.iteration.to_reference(format: :name) }
        end
        execution_message do
          _("Removed %{iteration_reference} iteration.") % { iteration_reference: quick_action_target.iteration.to_reference(format: :name) }
        end
        types Issue
        condition do
          quick_action_target.persisted? &&
            quick_action_target.sprint_id? &&
            quick_action_target.project.group&.feature_available?(:iterations) &&
            current_user.can?(:"admin_#{quick_action_target.to_ability_name}", project)
        end
        command :remove_iteration do
          @updates[:iteration] = nil
        end

        desc _('Publish to status page')
        explanation _('Publishes this issue to the associated status page.')
        types Issue
        condition do
          StatusPage::MarkForPublicationService.publishable?(project, current_user, quick_action_target)
        end
        command :publish do
          if StatusPage.mark_for_publication(project, current_user, quick_action_target).success?
            StatusPage.trigger_publish(project, current_user, quick_action_target, action: :init)
            info _('Issue published on status page.')
          else
            warn _('Failed to publish issue on status page.')
          end
        end

        helpers do
          def epics_available?
            issue.project.group&.feature_available?(:epics)
          end

          def issue
            quick_action_target
          end

          def extract_epic(params)
            return if params.nil?

            extract_references(params, :epic).first
          end

          def find_iterations(project, params = {})
            group_ids = project.group.self_and_ancestors.map(&:id) if project.group

            ::IterationsFinder.new(current_user, params.merge(project_ids: [project.id], group_ids: group_ids)).execute
          end
        end
      end
    end
  end
end
