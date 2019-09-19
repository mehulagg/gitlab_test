# frozen_string_literal: true

module Analytics
  module CodeAnalytics
    class RepositoryFile < ApplicationRecord
      belongs_to :project

      self.table_name = 'analytics_repository_files'
    end
  end
end
