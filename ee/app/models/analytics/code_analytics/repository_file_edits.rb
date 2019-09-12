# frozen_string_literal: true

module Analytics
  module CodeAnalytics
    class RepositoryFileEdits < ApplicationRecord
      belongs_to :project
      has_one :analytics_repository_file, class_name: 'Analytics::CodeAnalytics::RepositoryFile', foreign_key: :analytics_repository_file_edits_id
      has_one :analytics_repository_commit, class_name: 'Analytics::CodeAnalytics::RepositoryCommit', foreign_key: :analytics_repository_file_edits_id

      self.table_name = 'analytics_repository_file_edits'
    end
  end
end
