# frozen_string_literal: true

require_relative '../../support/helpers/ee/test_env'
require 'securerandom'

FactoryBot.define do
  factory :analytics_repository_file, class: "Analytics::CodeAnalytics::RepositoryFile"do
    project
    file_path "app/db/migrate/file.rb"
  end

  factory :analytics_repository_commit, class: "Analytics::CodeAnalytics::RepositoryCommit" do
    project
    commit_id { SecureRandom.hex }
    committed_date { DateTime.now }
  end

  factory :analytics_repository_file_edits, class: "Analytics::CodeAnalytics::RepositoryFileEdits" do
    project
    num_edits 5
    analytics_repository_file_id { create(:analytics_repository_file, file_path: file_path, project: project).id }
    analytics_repository_commit_id { create(:analytics_repository_commit, project: project).id }

    transient do
      file_path "app/db/migrate/file.rb"
    end
  end
end
