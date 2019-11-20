# frozen_string_literal: true

# Create a separate process, which does not load the Rails environment, to index
# each repository. This prevents memory leaks in the indexer from affecting the
# rest of the application.
module Gitlab
  module Elastic
    class Indexer
      Error = Class.new(StandardError)

      class << self
        def run(project, to_sha: nil, wiki: false)
          repository = wiki ? project.wiki.repository : project.repository
          targets = repository.__elasticsearch__.elastic_writing_targets

          targets.each do |target|
            Indexer.new(project, repository, target).run(to_sha)
          end
        end

        def indexer_version
          Rails.root.join('GITLAB_ELASTICSEARCH_INDEXER_VERSION').read.chomp
        end
      end

      attr_reader :project, :repository, :target, :index, :index_status

      def initialize(project, repository, target)
        @project = project
        @repository = repository
        @target = target

        @index = target.es_index
        @index_status = project.index_statuses.for_index(index).first
      end

      def run(to_sha = nil)
        to_sha = nil if to_sha == Gitlab::Git::BLANK_SHA

        if repository.empty?
          delete_indexed_data
          update_index_status(Gitlab::Git::BLANK_SHA)
          return
        end

        if last_commit.present? && repository.commit(last_commit).present?
          from_sha = last_commit
        else
          from_sha = Gitlab::Git::EMPTY_TREE_ID
          delete_indexed_data
        end

        run_indexer!(from_sha, to_sha)
        update_index_status(to_sha)
      end

      private

      def wiki?
        repository.repo_type == Gitlab::GlRepository::WIKI
      end

      def run_indexer!(from_sha, to_sha)
        # We accept any form of settings, including string and array
        # This is why JSON is needed
        vars = {
          'RAILS_ENV'               => Rails.env,
          'ELASTIC_CONNECTION_INFO' => elasticsearch_connection_info.to_json,
          'GITALY_CONNECTION_INFO'  => gitaly_connection_info.to_json,
          'FROM_SHA'                => from_sha,
          'TO_SHA'                  => to_sha
        }

        path_to_indexer = Gitlab.config.elasticsearch.indexer_path

        command =
          if wiki?
            [path_to_indexer, "--blob-type=wiki_blob", "--skip-commits", project.id.to_s, repository_path]
          else
            [path_to_indexer, project.id.to_s, repository_path]
          end

        output, status = Gitlab::Popen.popen(command, nil, vars)

        raise Error, output unless status&.zero?
      end

      def last_commit
        if wiki?
          index_status&.last_wiki_commit
        else
          index_status&.last_commit
        end
      end

      def repository_path
        "#{repository.disk_path}.git"
      end

      def elasticsearch_connection_info
        index.connection_config.merge(
          index_name: index.name
        ).tap do |config|
          # The indexer expects the :url key, rather than the :urls key we use on the Rails side.
          config[:url] = config.delete(:urls)
        end
      end

      def gitaly_connection_info
        Gitlab::GitalyClient.connection_data(project.repository_storage).merge(
          storage: project.repository_storage
        )
      end

      def update_index_status(to_sha)
        head_commit = repository.try(:commit)

        # An index_status should always be created,
        # even if the repository is empty, so we know it's been looked at.
        @index_status ||=
          begin
            project.index_statuses.find_or_create_by(elasticsearch_index_id: index.id) # rubocop: disable CodeReuse/ActiveRecord
          rescue ActiveRecord::RecordNotUnique
            # Race condition with another indexing job, let's try again to find the created record
            retry
          end

        # Don't update the index status if we never reached HEAD
        return if head_commit && to_sha && head_commit.sha != to_sha

        sha = head_commit.try(:sha)
        sha ||= Gitlab::Git::BLANK_SHA

        attributes =
          if wiki?
            { last_wiki_commit: sha, wiki_indexed_at: Time.now }
          else
            { last_commit: sha, indexed_at: Time.now }
          end

        index_status.update!(attributes)
      end

      def delete_indexed_data
        return unless index_status

        target.delete_index_for_commits_and_blobs(wiki: wiki?)
      end
    end
  end
end
