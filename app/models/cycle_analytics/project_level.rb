# frozen_string_literal: true

module CycleAnalytics
  class ProjectLevel
    include LevelBase
    attr_reader :project, :options

    def initialize(project, options:)
      @project = project
      @options = options.merge(project: project)
    end

    def summary
      @summary ||= ::Gitlab::ValueStreamAnalytics::StageSummary.new(project,
                                                              from: options[:from],
                                                              to: options[:to],
                                                              current_user: options[:current_user]).data
    end

    def permissions(user:)
      Gitlab::ValueStreamAnalytics::Permissions.get(user: user, project: project)
    end
  end
end
