# frozen_string_literal: true

module Gitlab
  class PagesTransfer < ProjectTransfer
    def root_dir
      Gitlab.config.pages.path
    end
    def update_config(project)
      force = true
      Projects::UpdatePagesConfigurationService.new(project).execute(force)
    end
  end
end
