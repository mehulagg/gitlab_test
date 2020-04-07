# frozen_string_literal: true

module Notes
  class UpdateService < BaseService
    def execute(note)
      return note unless note.editable? && params.present?

      old_mentioned_users = note.mentioned_users(current_user).to_a

      note.assign_attributes(params.merge(updated_by: current_user))

      note.with_transaction_returning_status do
        note.save
      end

      quick_actions_service = QuickActionsService.new(project, note, current_user)
      response = quick_actions_service.execute(note)

      note.note = response.content

      unless response.only_commands?
        note.create_new_cross_references!(current_user)
        update_todos(note, old_mentioned_users)
        update_suggestions(note)
      end

      if response.count > 0
        if response.updates.present?
          quick_actions_service.apply_updates(response.updates, note)
          note.commands_changes = update_params
        end

        if only_commands
          delete_note(note, response.messages, response.warnings)
          note = nil
        else
          note.save
        end
      end

      note
    end

    private

    def delete_note(note, message, warnings)
      # We must add the error after we call #save because errors are reset
      # when #save is called
      note.errors.add(:commands_only, message.presence || _('Commands did not apply'))
      # Allow consumers to detect problems applying commands
      note.errors.add(:commands, warnings) if warnings.present?

      Notes::DestroyService.new(project, current_user).execute(note)
    end

    def update_suggestions(note)
      return unless note.supports_suggestion?

      Suggestion.transaction do
        note.suggestions.delete_all
        Suggestions::CreateService.new(note).execute
      end

      # We need to refresh the previous suggestions call cache
      # in order to get the new records.
      note.reset
    end

    def update_todos(note, old_mentioned_users)
      return unless note.previous_changes.include?('note')

      TodoService.new.update_note(note, current_user, old_mentioned_users)
    end
  end
end

Notes::UpdateService.prepend_if_ee('EE::Notes::UpdateService')
