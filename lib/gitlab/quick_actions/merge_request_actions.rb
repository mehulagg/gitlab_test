# frozen_string_literal: true

module Gitlab
  module QuickActions
    module MergeRequestActions
      include Gitlab::QuickActions::Dsl

      helpers ::Gitlab::QuickActions::MergeRequestHelpers

      types MergeRequest

      command :merge do
        desc do
          if use_merge_orchestration_service?
            preferred_strategy_message(
              _("Merge automatically (%{strategy})"),
              _("Merge immediately")
            )
          else
            _('Merge (when the pipeline succeeds)')
          end
        end
        explanation do
          if use_merge_orchestration_service?
            preferred_strategy_message(
              _("Schedules to merge this merge request (%{strategy})."),
              _('Merges this merge request immediately.')
            )
          else
            _('Merges this merge request when the pipeline succeeds.')
          end
        end
        execution_message do
          if use_merge_orchestration_service?
            preferred_strategy_message(
              _("Scheduled to merge this merge request (%{strategy})."),
              _('Merged this merge request.')
            )
          else
            _('Scheduled to merge this merge request when the pipeline succeeds.')
          end
        end
        condition do
          if use_merge_orchestration_service?
            mergeable? &&
              merge_orchestration_service.can_merge?(quick_action_target)
          else
            mergeable? &&
              quick_action_target.mergeable_with_quick_action?(current_user, autocomplete_precheck: !diff_head_sha, last_diff_sha: diff_head_sha)
          end
        end
        action do
          update(merge: diff_head_sha)
        end

        # Provides mergeable?
        helpers ::Gitlab::QuickActions::MergeRequestHelpers

        helpers do
          def diff_head_sha
            @diff_head_sha ||= params[:merge_request_diff_head_sha]
          end

          def preferred_strategy_message(with_strategy, otherwise)
            if preferred_strategy
              with_strategy % { strategy: preferred_strategy.humanize }
            else
              otherwise
            end
          end
        end
      end

      command :wip do
        desc 'Toggle the Work In Progress status'

        explanation do
          message(
            _("Unmarks this %{noun} as Work In Progress."),
            _("Marks this %{noun} as Work In Progress.")
          )
        end
        execution_message do
          message(
            _("Unmarked this %{noun} as Work In Progress."),
            _("Marked this %{noun} as Work In Progress.")
          )
        end

        condition do
          quick_action_target.respond_to?(:work_in_progress?) &&
            # Allow it to mark as WIP on MR creation page _or_ through MR notes.
            (quick_action_target.new_record? || can_ability?(:update))
        end

        action { update(wip_event: wip? ? 'unwip' : 'wip') }

        helpers do
          def wip?
            quick_action_target.work_in_progress?
          end

          def message(wip, not_wip)
            noun = quick_action_target.to_ability_name.humanize(capitalize: false)
            (wip? ? wip : not_wip) % { noun: noun }
          end
        end
      end

      command :target_branch do
        desc _('Set target branch')
        params '<Local branch name>'
        strips_param

        explanation do |branch_name|
          _('Sets target branch to %{branch_name}.') % { branch_name: branch_name }
        end
        execution_message do |branch_name|
          if project.repository.branch_exists?(branch_name)
            _('Set target branch to %{branch_name}.') % { branch_name: branch_name }
          end
        end
        condition do
          quick_action_target.respond_to?(:target_branch) &&
            (can_ability?(:update) || quick_action_target.new_record?)
        end
        action do |branch_name|
          if project.repository.branch_exists?(branch_name)
            update(target_branch: branch_name)
          else
            warn _('No branch named %{branch_name}.') % { branch_name: branch_name }
          end
        end
      end

      command :submit_review do
        desc _('Submit a review')
        explanation _('Submit the current review.')
        condition do
          merge_request.persisted? && merge_request.project.feature_available?(:batch_comments, current_user)
        end
        action do
          next if params[:review_id]

          result = DraftNotes::PublishService.new(merge_request, current_user).execute
          if result[:status] == :success
            info _('Submitted the current review.')
          else
            warn result[:message]
          end
        end
      end
    end
  end
end
