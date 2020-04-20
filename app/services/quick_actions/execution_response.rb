# frozen_string_literal: true

module QuickActions
  class ExecutionResponse
    attr_reader :content, :updates, :messages, :count

    def initialize(content, user, updates: {}, messages: '', warnings: '', count: 0, commands: [])
      @content = content
      @current_user = user
      @updates = updates.freeze
      @messages = messages
      @warnings = warnings
      @count = count
      @commands = commands.freeze
    end

    def warnings
      if @warnings.blank? && commands.present? && commands.size != count
        not_run = [0, commands.size - count].max
        @warnings = n_('Failed to apply one command.', 'Failed to apply %{n} commands.', not_run) % { n: not_run }
      else
        @warnings
      end
    end

    def only_commands?
      content.blank? && commands.present?
    end

    def apply(update_service, resource_parent, updateable)
      return if noop?

      update_service.new(resource_parent, current_user, updates.dup).execute(updateable)
    end

    def noop?
      updates.empty?
    end

    def command_failure?
      only_commands? && messages.blank?
    end

    private

    attr_reader :commands, :current_user
  end
end
