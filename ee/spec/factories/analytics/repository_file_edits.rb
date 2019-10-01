# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_repository_file_edits, class: 'Analytics::CodeAnalytics::RepositoryFileEdits' do
    project
    num_edits 5
    analytics_repository_file
    committed_date { Date.today }
  end
end
