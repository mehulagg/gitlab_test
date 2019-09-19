# frozen_string_literal: true

module Analytics
  module CodeAnalytics
    class RepositoryFileEdits < ApplicationRecord
      belongs_to :project
      belongs_to :analytics_repository_file, class_name: 'Analytics::CodeAnalytics::RepositoryFile'

      self.table_name = 'analytics_repository_file_edits'
    end
  end
end
