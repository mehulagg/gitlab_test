# frozen_string_literal: true

# QuickActionsService class
#
# Executes quick actions commands extracted from note text
#
# Most commands returns parameters to be applied later
# using QuickActionService#apply_updates
#
module Notes
  class QuickActionsService < BaseService
    attr_reader :interpret_service

    delegate :commands_executed_count, to: :interpret_service, allow_nil: true

    UPDATE_SERVICES = {
      'Issue' => Issues::UpdateService,
      'MergeRequest' => MergeRequests::UpdateService,
      'Commit' => Commits::TagService
    }.freeze
    private_constant :UPDATE_SERVICES

    def self.update_services
      UPDATE_SERVICES
    end

    def self.noteable_update_service(note)
      update_services[note.noteable_type]
    end

    def self.supported?(note)
      !!noteable_update_service(note)
    end

    def supported?(note)
      self.class.supported?(note)
    end

    def execute(note, options = {})
      @interpret_service = QuickActions::InterpretService.new(project, note.noteable, current_user, note.note, options)
      if supported?(note)
        @interpret_service.execute
      else
        @interpret_service.null_response
      end
    end

    # Applies updates extracted to note#noteable
    # @param [QuickActions::ExecutionResponse] execution_response
    # @param [Note] note
    def self.apply_updates(execution_response, note)
      return unless supported?(note)

      execution_response.apply(noteable_update_service(note),
                               note.resource_parent, note.noteable)
      note.commands_changes = execution_response.updates
    end
  end
end

Notes::QuickActionsService.prepend_if_ee('EE::Notes::QuickActionsService')
