# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class that will fill the project_repositories table for projects that
    # are on hashed storage and an entry is is missing in this table.
    class BackfillSnippetRepositories
      MAX_RETRIES = 2

      def perform(start_id, stop_id)
        Snippet.where(id: start_id..stop_id).find_each do |snippet|
          next if repository_exists?(snippet)

          retry_index = 0

          begin
            create_repository_and_files(snippet)

            logger.info(message: 'Snippet Migration: repository created and migrated', snippet: snippet.id)
          rescue => e
            retry_index += 1

            retry if retry_index < MAX_RETRIES

            clean_snippet(snippet)

            logger.error(message: "Snippet Migration: error migrating snippet. Reason: #{e.message}", snippet: snippet.id)
          end
        end
      end

      private

      def repository_exists?(snippet)
        snippet.snippet_repository && !snippet.repository.empty?
      end

      def create_repository_and_files(snippet)
        snippet.create_repository
        create_commit(snippet)
      end

      def clean_snippet(snippet)
        # Removing the repository in disk
        snippet.snippet_repository&.destroy
        # Removing the db record
        snippet.repository.remove if snippet.repository_exists?
      end

      def logger
        @logger ||= Gitlab::BackgroundMigration::Logger.build
      end

      def snippet_action(snippet)
        # We don't need the previous_path param
        # Because we're not updating any existing file
        [{ file_path: filename(snippet),
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
