# frozen_string_literal: true

class PagesDeleteCleanupWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: 3
  feature_category :pages
  loggable_arguments 0, 1

  def perform(namespace_path, project_path)
    full_path = File.join(Settings.pages.path, namespace_path, project_path)
    FileUtils.rm_r(full_path, force: true)
  end
end
