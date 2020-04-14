# frozen_string_literal: true

module QuickActions
  class ExecutionResponse
    attr_reader :content, :updates, :messages, :warnings, :count

    def initialize(content, user, updates: {}, messages: '', warnings: '', count: 0, commands: [])
      @content = content
      @current_user = user
      @updates = updates.freeze
      @messages = messages
      @warnings = warnings
      @count = count
      @commands = commands.freeze
    end

    def only_commands?
      content.blank? && commands.present?
    end

    def apply(update_service, resource_parent, updateable)
      return if noop?

      update_service.new(resource_parent, current_user, updates).execute(updateable)
    end

    def noop?
      updates.empty?
    end

    private

    attr_reader :commands, :current_user
  end
end
