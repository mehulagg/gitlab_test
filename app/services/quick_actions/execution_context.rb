# frozen_string_literal: true

module QuickActions
  # Blocks defined in the QuickActions DSL are executed in this context, with
  # the following methods made available
  class ExecutionContext
    include Gitlab::Utils::StrongMemoize

    attr_reader :updates

    delegate :project, :current_command, :current_user, :quick_action_target,
             to: :interpret_service

    def initialize(interpret_service, messages, warnings, commands)
      @interpret_service = interpret_service # Commands should not access this directly
      @commands_executed_count = 0
      @execution_message = messages
      @execution_warning = warnings
      @commands_executed = commands
      @updates = {}
      @parameters = {}
    end

    def warn(message)
      @execution_warning[current_command] = message
      nil
    end

    def info(message)
      if @execution_message[current_command]
        @execution_message[current_command] += " #{message}"
      else
        @execution_message[current_command] = message
      end
    end

    def record_command_execution
      @commands_executed << current_command
    end

    def update(updates)
      @updates.merge!(updates)
    end

    def modify(key, &block)
      @updates[key] = yield(@updates[key])
    end

    def params
      interpret_service.params&.dup || {}
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

    # rubocop: disable CodeReuse/ActiveRecord
    def extract_references(arg, type)
      return [] unless arg

      ext = Gitlab::ReferenceExtractor.new(project, current_user)

      ext.analyze(arg, author: current_user, group: group)

      ext.references(type)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    attr_reader :interpret_service
  end
end
