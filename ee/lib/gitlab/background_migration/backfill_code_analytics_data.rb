# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class BackfillCodeAnalyticsData
      NUM_DAYS_TO_BACKFILL = 30
      BATCH_SIZE = 1_000

      class File < ActiveRecord::Base
        include ::EachBatch

        self.table_name = 'analytics_repository_files'
      end

      class FileEdits < ActiveRecord::Base
        include ::EachBatch

        self.table_name = 'analytics_repository_file_edits'
      end

      # estimation: 100000 projects on gitlab.com
      # check: if not ee, check for premium license
      # scope: commits in the last 30 days, where the related repo is from a project that has premium license
      # can this be a join over commits, repos?
      # where are commits stored in the db?

      # This runs at least 30 queries to gather commits and at least 30 upsert queries
      def perform(start_id, end_id)
        (1..NUM_DAYS_TO_BACKFILL).each do |days|
          date = Date.today - days

          commits_on(date).each_batch(of: BATCH_SIZE).each do |commit|
            edited_files(commit).each do |file, num_edits|
              upsert_repo_file_edits(file, num_edits, project, date)
            end
          end
        end
      end

      private

      def commits_on(date)
        # Repository.commits_between()
        # Gitlab::Git::Commit.find_all(
        #   repo: ,
        #   order: :date
        # )



          #.where(committed_date: date).where(id: start_id..end_id)
      end

      def upsert_repo_file_edits(file, new_edits, project, date)
        repo_file = File.upsert(
          file_path: file.file_path,
          project: project
        )

        FileEdits.upsert(
          analytics_repository_file: repo_file,
          committed_date: date,
          project: project,
          num_edits: num_edits + new_edits #fixme: add to the original value
        )
        # Upsert query in postgresql
        # https://blog.bitexpert.de/blog/upsert-with-postgresql/
      end

      def edited_files(commit)
      end
    end
  end
end
