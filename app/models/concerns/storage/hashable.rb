# frozen_string_literal: true

module Storage
  module Hashable
    include Gitlab::Utils::StrongMemoize
    extend ActiveSupport::Concern

    attr_reader :container, :prefix

    delegate :repository_storage, to: :container

    POOL_PATH_PREFIX = '@pools'

    def initialize(container, prefix: repository_path_prefix)
      @container = container
      @prefix = prefix
    end

    # Base directory
    #
    # @return [String] directory where repository is stored
    def base_dir
      "#{prefix}/#{disk_hash[0..1]}/#{disk_hash[2..3]}" if disk_hash
    end

    # Disk path is used to build repository path on disk
    #
    # @return [String] combination of base_dir and the repository own name without `.git` or `.wiki.git` extensions
    def disk_path
      "#{base_dir}/#{disk_hash}" if disk_hash
    end

    def rename_repo(old_full_path: nil, new_full_path: nil)
      true
    end

    private

    def repository_path_prefix
      '@hashed'
    end

    # Generates the hash for the project path and name on disk
    # If you need to refer to the repository on disk, use the `#disk_path`
    def disk_hash
      strong_memoize(:disk_hash) do
        next unless container

        Digest::SHA2.hexdigest(container.id.to_s)
      end
    end
  end
end
