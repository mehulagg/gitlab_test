# frozen_string_literal: true

module Praefect
  class ReplicationWorker
    include ApplicationWorker

    feature_category :source_code_management

    sidekiq_options retry: false

    def perform(target_storage, source_storage, relative_path, gl_repository, gl_project_path)
      target_repo = Gitlab::Git::Repository.new(target_storage, relative_path, gl_repository, gl_project_path)
      source_repo = Gitlab::Git::Repository.new(source_storage, relative_path, gl_repository, gl_project_path)

      target_repo.replicate_repository(source_repo)
    end
  end
end
