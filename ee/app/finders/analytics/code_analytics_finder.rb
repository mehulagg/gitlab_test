# frozen_string_literal: true

module Analytics
  class CodeAnalyticsFinder
    MAX_FILES = 100

    attr_reader :project, :from, :to

    def initialize(project:, from:, to:)
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

    def files
      Analytics::CodeAnalytics::RepositoryFile.arel_table
    end

    def file_edits
      Analytics::CodeAnalytics::RepositoryFileEdits.arel_table
    end

    def query
      file_edits
        .join(files)
        .on(files[:id].eq(file_edits[:analytics_repository_file_id]))
        .where(file_edits[:project_id].eq(project.id))
        .where(file_edits[:committed_date].gteq(from))
        .where(file_edits[:committed_date].lteq(to))
        .group(files[:file_path])
        .project(files[:file_path], file_edits[:num_edits].sum)
        .take(MAX_FILES)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
