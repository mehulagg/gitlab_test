# frozen_string_literal: true

module QuickActions
  class InterpretService < BaseService
    include Gitlab::Utils::StrongMemoize
    include Gitlab::QuickActions::Dsl
    include Gitlab::QuickActions::IssueActions
    include Gitlab::QuickActions::IssuableActions
    include Gitlab::QuickActions::IssueAndMergeRequestActions
    include Gitlab::QuickActions::MergeRequestActions
    include Gitlab::QuickActions::CommitActions
    include Gitlab::QuickActions::CommonActions

    ExecutionResponse = Struct.new(:content, :updates, :messages, :warnings, :count, :only_commands?)

    attr_reader :quick_action_target, :content

    # Counts how many commands have been executed.
    # Used to display relevant feedback on UI when a note
    # with only commands has been processed.
    attr_reader :commands_executed_count

    def initialize(project, target, user = nil, content = nil, params = {})
      super(project, user, params)
      @quick_action_target = target
      @content = content
      @updates = {}
      @execution_message = {}
      @execution_warning = {}
      @commands_executed_count = 0
    end

    def self.null_explanation(content)
      ExplainResponse.new(content, [])
    end

    # Takes an quick_action_target and returns an array of all the available commands
    # represented with .to_h
    def available_commands
      self.class.command_definitions.map do |definition|
        next unless definition.available?(self)

        definition.to_h(self)
      end.compact
    end

    # Takes a text and interprets the commands that are extracted from it.
    # Returns an ExecutionResponse
    def execute(only: nil)
      return null_response unless current_user.can?(:use_quick_actions)

      trimmed_content, commands = extractor.extract_commands(content, only: only)
      run_definitions(commands)

      ExecutionResponse.new(trimmed_content, @updates,
                            execution_messages_for(commands),
                            execution_warnings_for(commands),
                            commands_executed_count,
                            trimmed_content.empty?)
    end

    def null_response
      ExecutionResponse.new(content, {}, '', '', 0, false)
    end

    ExplainResponse = Struct.new(:content, :messages)

    # Takes a text and interprets the commands that are extracted from it.
    # Returns the content without commands, and array of changes explained.
    def explain
      return ExplainResponse.new(content, []) unless current_user.can?(:use_quick_actions)

      trimmed_content, commands = extractor.extract_commands(content)
      ExplainResponse.new(trimmed_content, explain_commands(commands))
    end

    # Available to commands
    def record_command_execution
      self.commands_executed_count += 1
    end

    def warn(message)
      @execution_warning[@current_name] = message
      nil
    end

    def info(message)
      if @execution_message[@current_name]
        @execution_message[@current_name] << " #{message}"
      else
        @execution_message[@current_name] = message
      end
    end

    private

    attr_writer :commands_executed_count

    def extractor
      @extractor ||= Gitlab::QuickActions::Extractor.new(self.class.command_definitions)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def extract_users(params)
      return [] if params.nil?

      users = extract_references(params, :user)

      if users.empty?
        users =
          if params.strip == 'me'
            [current_user]
          else
            User.where(username: params.split(' ').map(&:strip))
          end
      end

      users
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def find_milestones(project, params = {})
      group_ids = project.group.self_and_ancestors.select(:id) if project.group

      MilestonesFinder.new(params.merge(project_ids: [project.id], group_ids: group_ids)).execute
    end

    def parent
      project || group
    end

    def group
      strong_memoize(:group) do
        quick_action_target.group if quick_action_target.respond_to?(:group)
      end
    end

    def find_labels(labels_params = nil)
      extract_references(labels_params, :label) | find_labels_by_name_no_tilde(labels_params)
    end

    def find_labels_by_name_no_tilde(labels_params)
      return Label.none if label_with_tilde?(labels_params)

      finder_params = { include_ancestor_groups: true }
      finder_params[:project_id] = project.id if project
      finder_params[:group_id] = group.id if group
      finder_params[:name] = extract_label_names(labels_params) if labels_params

      LabelsFinder.new(current_user, finder_params).execute
    end

    def label_with_tilde?(labels_params)
      labels_params&.include?('~')
    end

    def extract_label_names(labels_params)
      # '"A" "A B C" A B' => ["A", "A B C", "A", "B"]
      labels_params.scan(/"([^"]+)"|([^ ]+)/).flatten.compact
    end

    def find_label_references(labels_param, format = :id)
      labels_to_reference(find_labels(labels_param), format)
    end

    def labels_to_reference(labels, format = :id)
      labels.map { |l| l.to_reference(format: format) }
    end

    def find_label_ids(labels_param)
      find_labels(labels_param).map(&:id)
    end

    def explain_commands(commands)
      map_commands(commands, :explain)
    end

    def execution_messages_for(commands)
      map_commands(commands, :execute_message).uniq.join(' ')
    end

    def execution_warnings_for(commands)
      map_commands(commands, :execution_warning).join(' ')
    end

    def map_commands(commands, method)
      commands.map do |name, arg|
        definition = self.class.definition_by_name(name)
        next unless definition

        case method
        when :explain
          with_name(name) { definition.explain(self, arg) }
        when :execute_message
          @execution_message[name.to_sym] || definition.execute_message(self, arg)
        when :execution_warning
          # run execution message block to capture warnings
          with_name(name) { definition.execute_message(self, arg) }
          @execution_warning[name.to_sym]
        end
      end.compact
    end

    def run_definitions(commands)
      commands.each do |name, arg|
        definition = self.class.definition_by_name(name)
        next unless definition

        with_name(name) { definition.execute(self, arg) }
      end
    end

    def with_name(name)
      @current_name = name.to_sym
      ret = yield
      @current_name = nil
      ret
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def extract_references(arg, type)
      return [] unless arg

      ext = Gitlab::ReferenceExtractor.new(project, current_user)

      ext.analyze(arg, author: current_user, group: group)

      ext.references(type)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end

QuickActions::InterpretService.prepend_if_ee('EE::QuickActions::InterpretService')
