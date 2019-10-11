# frozen_string_literal: true

module Ci
  class Config
    include Gitlab::Utils::StrongMemoize

    def initialize(pipeline)
      @pipeline = pipeline
    end

    def source
      strong_memoize(:source) do
        if ci_yaml_from_repo
          :repository_source
        elsif implied_ci_yaml_file
          :auto_devops_source
        else
          # no yaml found
        end
      end
    end

    def content
      strong_memoize(:content) do
        content = case source
                  when :auto_devops_source
                    implied_ci_yaml_file
                  else
                    # TODO: why are we looking at the yaml in the repo
                    # if source is unknown? shouldn't we do that only if
                    # source is :repository_source?
                    ci_yaml_from_repo
                  end

        unless content
          pipeline.yaml_errors = "Failed to load CI/CD config file for #{sha}"
        end

        content
      end
    end

    def path
      return unless pipeline.repository_source? || pipeline.unknown_source?

      project.ci_config_path.presence || '.gitlab-ci.yml'
    end

    private

    attr_reader :pipeline

    def ci_yaml_from_repo
      return unless project
      return unless sha
      return unless path

      project.repository.gitlab_ci_yml_for(sha, path)
    rescue GRPC::NotFound, GRPC::Internal
      nil
    end

    def implied_ci_yaml_file
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
