# frozen_string_literal: true

module Analytics
  module CodeAnalytics
    class RepositoryFile < ApplicationRecord
      belongs_to :project
      belongs_to :analytics_repository_file_edits, class_name: "Analytics::CodeAnalytics::RepositoryFileEdits", foreign_key: :analytics_repository_file_edits_id

      self.table_name = 'analytics_repository_files'
    end
  end
end
