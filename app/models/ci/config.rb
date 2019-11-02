# frozen_string_literal: true

# TODO: change this class to Ci::Pipeline::Config
# as it represent the config for a specific pipeline
module Ci
  class Config
    include Gitlab::Utils::StrongMemoize

    attr_reader :content, :source

    def initialize(pipeline)
      @pipeline = pipeline
      load_data!

      # TODO: move this outside into the pipeline chain
      pipeline.yaml_errors = "Failed to load CI/CD config file for #{sha}" unless @content
    end

    def path
      return if auto_devops_source?

      project.ci_config_path.presence || '.gitlab-ci.yml'
    end

    private

    attr_reader :pipeline

    def load_data!
      if @content = content_from_repo
        @source = :repository_source
      elsif @content = content_from_auto_devops
        @source = :auto_devops_source
      end
    end

    def auto_devops_source?
      source == :auto_devops_source
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

    def project
      @project ||= pipeline.project
    end

    def sha
      @sha ||= pipeline.sha
    end
  end
end
