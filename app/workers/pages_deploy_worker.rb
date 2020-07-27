# frozen_string_literal: true

class PagesDeployWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: 3
  feature_category :pages
  loggable_arguments 0

  def perform(build_id)
    build = Ci::Build.find_by(id: build_id) # rubocop: disable CodeReuse/ActiveRecord

    update_contents = Projects::UpdatePagesService.new(build.project, build).execute

    if update_contents[:status] == :success
      Projects::UpdatePagesConfigurationService.new(build.project).execute
    end
  end
end
