# frozen_string_literal: true

module Notes
  class CreateService < ::Notes::BaseService
    def execute
      note = Notes::BuildService.new(project, current_user, params.except(:merge_request_diff_head_sha)).execute

      # n+1: https://gitlab.com/gitlab-org/gitlab-foss/issues/37440
      note_valid = Gitlab::GitalyClient.allow_n_plus_1_calls do
        # We may set errors manually in Notes::BuildService for this reason
        # we also need to check for already existing errors.
        note.errors.empty? && note.valid?
      end

      return note unless note_valid

      execute_quick_actions(note) do |should_save|
        note.run_after_commit do
          # Finish the harder work in the background
          NewNoteWorker.perform_async(note.id)
        end

        note_saved = note.with_transaction_returning_status do
          should_save && note.save
        end

        when_saved(note) if note_saved
      end

      note
    end

    private

    def execute_quick_actions(note)
      return yield(true) unless quick_actions_service.supported?(note)

      response = quick_actions_service.execute(note, quick_action_options)
      note.note = response.content

      yield(!response.only_commands?)

      do_commands(note, response)
      report_command_messages(note, response) if response.only_commands?
    end

    def quick_actions_service
      @quick_actions_service ||= QuickActionsService.new(project, current_user)
    end

    def when_saved(note)
      if note.part_of_discussion? && note.discussion.can_convert_to_discussion?
        note.discussion.convert_to_discussion!(save: true)
      end

      todo_service.new_note(note, current_user)
      clear_noteable_diffs_cache(note)
      Suggestions::CreateService.new(note).execute
      increment_usage_counter(note)

      if Feature.enabled?(:notes_create_service_tracking, project)
        Gitlab::Tracking.event('Notes::CreateService', 'execute', tracking_data_for(note))
      end

      if Feature.enabled?(:merge_ref_head_comments, project) && note.for_merge_request? && note.diff_note? && note.start_of_discussion?
        Discussions::CaptureDiffNotePositionService.new(note.noteable, note.diff_file&.paths).execute(note.discussion)
      end
    end

    def do_commands(note, execution_response)
      return if execution_response.count.zero? || execution_response.updates.empty?

      quick_actions_service.apply_updates(execution_response.updates, note)
      note.commands_changes = execution_response.updates
    end

    # Execution messages are reported in a side channel in the errors messages
    def report_command_messages(note, execution_response)
      warnings = execution_response.warnings
      message = execution_response.messages

      note.errors.add(:commands, warnings) if warnings.present?
      note.errors.add(:commands_only, message.presence || _('Failed to apply commands.'))
    end

    def quick_action_options
      {
        merge_request_diff_head_sha: params[:merge_request_diff_head_sha],
        review_id: params[:review_id]
      }
    end

    def tracking_data_for(note)
      label = Gitlab.ee? && note.author == User.visual_review_bot ? 'anonymous_visual_review_note' : 'note'

      {
        label: label,
        value: note.id
      }
    end
  end
end
