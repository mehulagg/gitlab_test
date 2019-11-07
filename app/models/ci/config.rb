# frozen_string_literal: true

# This class represents the actual pipeline configuration.
# It defines the logic for finding the config content, path and source
# that is used to trigger a pipeline, even when multiple configurations
# are provided (e.g. Auto-DevOps and file in repo)
module Ci
  class Config
    include Gitlab::Utils::StrongMemoize

    def initialize(project, sha)
      @project = project
      @sha = sha
    end

    def content
      @content ||= data[:content]
    end

    def source
      @source ||= data[:source]
    end

    def path
      return if auto_devops_source?

      project.ci_config_path.presence || '.gitlab-ci.yml'
    end

    private

    attr_reader :project, :sha

    def data
      strong_memoize(:data) do
        if content = content_from_repo
          { content: content, source: :repository_source }
        elsif content = content_from_auto_devops
          { content: content, source: :auto_devops_source }
        else
          {}
        end
      end
    end

    def auto_devops_source?
      @source == :auto_devops_source
    end

    def content_from_repo
      return unless project
      return unless sha
      return unless path

      project.repository.gitlab_ci_yml_for(sha, path)
    rescue GRPC::NotFound, GRPC::Internal
      nil
    end

    def content_from_auto_devops
      return unless project&.auto_devops_enabled?

      Gitlab::Template::GitlabCiYmlTemplate.find('Auto-DevOps').content
    end
  end
end
