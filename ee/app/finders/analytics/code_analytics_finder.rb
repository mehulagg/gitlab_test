# frozen_string_literal: true

module Analytics
  class CodeAnalyticsFinder
    def initialize(project, from, to)
      @project = project
      @from, @to = from, to
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      flatten ActiveRecord::Base.connection.execute(query.to_sql).values
    end

    private

    def flatten(results)
      Hash[*results.flatten]
    end

    def commits
      Analytics::CodeAnalytics::RepositoryCommit.arel_table
    end

    def files
      Analytics::CodeAnalytics::RepositoryFile.arel_table
    end

    def file_edits
      Analytics::CodeAnalytics::RepositoryFileEdits.arel_table
    end

    def query
      file_edits
        .join(commits)
        .on(commits[:id].eq(file_edits[:analytics_repository_commit_id]))
        .where(commits[:committed_date].gteq(@from))
        .where(commits[:committed_date].lteq(@to))
        .join(files)
        .on(files[:id].eq(file_edits[:analytics_repository_file_id]))
        .where(file_edits[:project_id].eq(@project.id))
        .group(files[:file_path])
        .project(files[:file_path], file_edits[:num_edits].sum)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
