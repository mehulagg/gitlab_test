# frozen_string_literal: true

module Storage
  class HashedNamespace
    attr_accessor :namespace
    delegate :gitlab_shell, :repository_storage, to: :namespace

    REPOSITORY_PATH_PREFIX = '@hashed/namespaces'
    POOL_PATH_PREFIX = '@pools'

    def initialize(namespace, prefix: REPOSITORY_PATH_PREFIX)
      @namespace = namespace
      @prefix = prefix
    end

    # Base directory
    #
    # @return [String] directory where repository is stored
    def base_dir
      "#{@prefix}/#{disk_hash[0..1]}/#{disk_hash[2..3]}" if disk_hash
    end

    # Disk path is used to build repository and project's wiki path on disk
    #
    # @return [String] combination of base_dir and the repository own name without `.git` or `.wiki.git` extensions
    def disk_path
      "#{base_dir}/#{disk_hash}" if disk_hash
    end

    def rename_repo(old_full_path: nil, new_full_path: nil)
      true
    end

    private

    # Generates the hash for the project path and name on disk
    # If you need to refer to the repository on disk, use the `#disk_path`
    def disk_hash
      @disk_hash ||= Digest::SHA2.hexdigest(namespace.id.to_s) if namespace.id
    end
  end
end
