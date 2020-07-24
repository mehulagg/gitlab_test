# frozen_string_literal: true

module Gitlab
  module GithubImport
    def self.refmap
      [:heads, :tags, '+refs/pull/*/head:refs/merge-requests/*/head']
    end

    def self.new_client_for(project, token: nil, parallel: true)
      token_to_use = token || project.import_data&.credentials&.fetch(:user)

      opts = {
        parallel: parallel
      }

      opts.merge!(self.gitea_opts(project)) if project.gitea_import?

      Client.new(token_to_use, opts)
    end

    # Returns the ID of the ghost user.
    def self.ghost_user_id
      key = 'github-import/ghost-user-id'

      Gitlab::Cache::Import::Caching.read_integer(key) || Gitlab::Cache::Import::Caching.write(key, User.select(:id).ghost.id)
    end

    def self.gitea_opts(project)
      uri = URI.parse(project.import_url)
      host = "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}".sub(%r{/?[\w-]+/[\w-]+\.git\z}, '')

      {
        host: host,
        api_version: 'v1'
      }
    end
  end
end
