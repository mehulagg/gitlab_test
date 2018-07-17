module Gitlab
  module Git
    class RevList
      include Gitlab::Git::Popen

      attr_reader :oldrev, :newrev, :repository

      def initialize(repository, newrev:, oldrev: nil)
        @oldrev = oldrev
        @newrev = newrev
        @repository = repository
      end

      # This method returns an array of new commit references
      # Gitaly migration: https://gitlab.com/gitlab-org/gitaly/issues/1233
      #
      def new_refs
        Gitlab::GitalyClient::StorageSettings.allow_disk_access do
          repository.rev_list(including: newrev, excluding: :all).split("\n")
        end
      end
      # Can skip objects which do not have a path using required_path: true
      # This skips commit objects and root trees, which might not be needed when
      # looking for blobs
      #
      # When given a block it will yield objects as a lazy enumerator so
      # the caller can limit work done instead of processing megabytes of data
      def new_objects(options: [], require_path: nil, include_path: nil, not_in: nil, &lazy_block)
        opts = {
          including: newrev,
          options: options,
          excluding: not_in.nil? ? :all : not_in,
          require_path: require_path,
          include_path: include_path
        }

        get_objects(opts, &lazy_block)
      end

      private

      def execute(args)
        repository.rev_list(args).split("\n")
      end

      def get_objects(including: [], excluding: [], options: [], require_path: nil, include_path: false)
        opts = { including: including, excluding: excluding, options: options, objects: true }

        repository.rev_list(opts) do |lazy_output|
          objects = objects_from_output(lazy_output, require_path: require_path, include_path: include_path)

          yield(objects)
        end
      end

      def objects_from_output(object_output, require_path: nil, include_path: nil)
        object_output.map do |output_line|
          sha, path = output_line.split(' ', 2)

          next if require_path && path.to_s.empty?

          include_path ? [sha, path.chomp] : sha
        end.reject(&:nil?)
      end
    end
  end
end
