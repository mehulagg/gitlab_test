# frozen_string_literal: true

module Ci
  class RunDastScanService
    DAST_CI_TEMPLATE = "lib/gitlab/ci/templates/Security/DAST.gitlab-ci.yml".freeze
    DEFAULT_SHA_FOR_PROJECTS_WITHOUT_COMMITS = :placeholder

    EXCEPTIONS = [
      NotAllowed = Class.new(StandardError),
      CreatePipelineError = Class.new(StandardError),
      CreateStageError = Class.new(StandardError),
      CreateBuildError = Class.new(StandardError),
      EnqueueError = Class.new(StandardError)
    ].freeze

    def self.ci_template
      @ci_template ||= File.open(DAST_CI_TEMPLATE, "r") { |f| YAML.safe_load(f.read) }
    end

    def initialize(project:, user:)
      @project = project
      @user = user
    end

    def execute(branch:, target_url:)
      raise NotAllowed unless allowed?

      ActiveRecord::Base.transaction do
        pipeline = create_pipeline!(branch)
        stage = create_stage!(pipeline)
        build = create_build!(pipeline, stage, branch, target_url)
        enqueue!(build)
        pipeline
      end
    end

    private

    attr_reader :project, :user

    def allowed?
      Ability.allowed?(user, :create_pipeline, project)
    end

    def create_pipeline!(branch)
      reraise!(with: CreatePipelineError.new('Could not create pipeline')) do
        Ci::Pipeline.create!(
          project: project,
          ref: branch,
          sha: project.repository.commit&.id || DEFAULT_SHA_FOR_PROJECTS_WITHOUT_COMMITS,
          source: :web,
          user: user
        )
      end
    end

    def create_stage!(pipeline)
      reraise!(with: CreateStageError.new('Could not create stage')) do
        Ci::Stage.create!(
          name: 'dast',
          pipeline: pipeline,
          project: project
        )
      end
    end

    def create_build!(pipeline, stage, branch, target_url)
      reraise!(with: CreateBuildError.new('Could not create build')) do
        Ci::Build.create!(
          name: 'On demand DAST scan',
          pipeline: pipeline,
          project: project,
          ref: branch,
          scheduling_type: :stage,
          stage: stage.name,
          options: options,
          yaml_variables: yaml_variables(target_url)
        )
      end
    end

    def enqueue!(build)
      reraise!(with: EnqueueError.new('Could not enqueue build')) do
        build.enqueue!
      end
    end

    def reraise!(with:)
      yield
    rescue => err
      Gitlab::ErrorTracking.track_exception(err)
      raise with
    end

    def options
      ci_template = self.class.ci_template

      {
        image: ci_template['dast']['image'],
        artifacts: ci_template['dast']['artifacts'],
        script: ci_template['dast']['script']
      }
    end

    def yaml_variables(target_url)
      ci_template = self.class.ci_template
      ci_template_variables = ci_template['variables'].merge(ci_template['dast']['variables'])

      ci_template_variables.map do |key, value|
        {
          key: key,
          value: value,
          public: true
        }
      end.push(
        key: 'DAST_WEBSITE',
        value: target_url,
        public: true
      )
    end
  end
end
