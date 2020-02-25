# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class that will fill the project_repositories table for projects that
    # are on hashed storage and an entry is is missing in this table.
    class BackfillSnippetRepositories
      MAX_RETRIES = 2

      def perform(start_id, stop_id)
        retry_index = 0

        Snippet.where(id: start_id..stop_id).find_each do |snippet|
          create_repository_and_files(snippet, retry_index)

          retry_index = 0
        end
      end

      private

      def create_repository_and_files(snippet, retry_index)
        Snippet.transaction do
          snippet.create_repository
          create_commit(snippet)

          logger.info(message: 'Snippet Migration: repository created and migrated', snippet: snippet.id)
        end
      rescue => e
        retry_index += 1

        retry if retry_index < MAX_RETRIES

        logger.error(message: "Snippet Migration: error migrating snippet. Reason: #{e.message}", snippet: snippet.id)
      end

      def logger
        @logger ||= Gitlab::BackgroundMigration::Logger.build
      end

      def snippet_action(snippet)
        file_path = filename(snippet)
        blob = snippet.repository.blob_at('master', file_path)

        [{ previous_path: blob&.path,
           file_path: file_path,
           content: snippet.content }]
      end

      def filename(snippet)
        snippet.file_name.presence || empty_file_name
      end

      def empty_file_name
        @empty_file_name ||= "#{SnippetRepository::DEFAULT_EMPTY_FILE_NAME}1.txt"
      end

      def commit_attrs
        @commit_attrs ||= { branch_name: 'master', message: 'Initial commit' }
      end

      def create_commit(snippet)
        snippet.snippet_repository.multi_files_action(snippet.author, snippet_action(snippet), commit_attrs)
      end
    end
  end
end



# Migration
# INTERVAL = 5.minutes.to_i
# BATCH_SIZE = 100
# MIGRATION = 'BackfillSnippetRepositories'

# Snippet.where.not(id: SnippetRepository.select(:snippet_id)).each_batch(of: BATCH_SIZE) do |batch, index|
#   range = batch.pluck('MIN(id)', 'MAX(id)').first
#   delay = index * INTERVAL
#   BackgroundMigrationWorker.perform_in(delay, MIGRATION, *range)
# end
