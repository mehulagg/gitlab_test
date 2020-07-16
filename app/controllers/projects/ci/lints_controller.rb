# frozen_string_literal: true

class Projects::Ci::LintsController < Projects::ApplicationController
  before_action :authorize_create_pipeline!

  def show
  end

  def create
    @content = params[:content]
    @dry_run = Gitlab::Ci::Features.lint_creates_pipeline_with_dry_run?(@project)

    if @dry_run
      pipeline = Ci::CreatePipelineService.new(@project, current_user, ref: 'master')
        .execute(:push, dry_run: true, content: @content)

      @status = pipeline.error_messages.empty?
      @errors = pipeline.error_messages.map(&:content)
      @warnings = pipeline.warning_messages.map(&:content)
    else
      result = Gitlab::Ci::YamlProcessor.new_with_validation_errors(@content, yaml_processor_options)

      @status = result.valid?
      @errors = result.errors

      if result.valid?
        @config_processor = result.config
        @stages = @config_processor.stages
        @builds = @config_processor.builds
        @jobs = @config_processor.jobs
      end
    end

    render :show
  end

  private

  def yaml_processor_options
    {
      project: @project,
      user: current_user,
      sha: project.repository.commit.sha
    }
  end
end
