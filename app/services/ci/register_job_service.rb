# frozen_string_literal: true

module Ci
  # This class responsible for assigning
  # proper pending build to runner on runner API request
  class RegisterJobService
    attr_reader :runner

    JOB_QUEUE_DURATION_SECONDS_BUCKETS = [1, 3, 10, 30, 60, 300, 900, 1800, 3600].freeze
    JOBS_RUNNING_FOR_PROJECT_MAX_BUCKET = 5.freeze
    METRICS_SHARD_TAG_PREFIX = 'metrics_shard::'.freeze
    DEFAULT_METRICS_SHARD = 'default'.freeze

    def initialize(runner)
      @runner = runner
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute(params = {})
      result = queueing_method.find do |build|
        process_build(build, params)
      end

      if result.build
        register_success(result.build)
      else
        register_failure
      end

      result
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def queueing_method
      ::Ci::Queueing::LegacyDatabaseMethod.new(runner)
    end

    def process_build(build, params)
      return :skip unless runner.can_pick?(build)

      # In case when 2 runners try to assign the same build, second runner will be declined
      # with StateMachines::InvalidTransition or StaleObjectError when doing run! or save method.
      if assign_runner!(build, params)
        :success
      else
        :skip
      end
    rescue StateMachines::InvalidTransition, ActiveRecord::StaleObjectError
      # We are looping to find another build that is not conflicting
      # It also indicates that this build can be picked and passed to runner.
      # If we don't do it, basically a bunch of runners would be competing for a build
      # and thus we will generate a lot of 409. This will increase
      # the number of generated requests, also will reduce significantly
      # how many builds can be picked by runner in a unit of time.
      # In case we hit the concurrency-access lock,
      # we still have to return 409 in the end,
      # to make sure that this is properly handled by runner.
      :conflict
    rescue => ex
      scheduler_failure!(build)
      track_exception_for_build(ex, build)

      # skip, and move to next one
      :skip
    end

    def assign_runner!(build, params)
      build.runner_id = runner.id
      build.runner_session_attributes = params[:session] if params[:session].present?

      unless build.has_valid_build_dependencies?
        build.drop!(:missing_dependency_failure)
        return false
      end

      unless build.supported_runner?(params.dig(:info, :features))
        build.drop!(:runner_unsupported)
        return false
      end

      if build.archived?
        build.drop!(:archived_failure)
        return false
      end

      build.run!
      true
    end

    def scheduler_failure!(build)
      Gitlab::OptimisticLocking.retry_lock(build, 3) do |subject|
        subject.drop!(:scheduler_failure)
      end
    rescue => ex
      build.doom!

      # This requires extra exception, otherwise we would loose information
      # why we cannot perform `scheduler_failure`
      track_exception_for_build(ex, build)
    end

    def track_exception_for_build(ex, build)
      Gitlab::ErrorTracking.track_exception(ex,
        build_id: build.id,
        build_name: build.name,
        build_stage: build.stage,
        pipeline_id: build.pipeline_id,
        project_id: build.project_id
      )
    end

    def register_failure
      failed_attempt_counter.increment
      attempt_counter.increment
    end

    def register_success(job)
      labels = { shared_runner: runner.instance_type?,
                 jobs_running_for_project: jobs_running_for_project(job),
                 shard: DEFAULT_METRICS_SHARD }

      if runner.instance_type?
        shard = runner.tag_list.sort.find { |name| name.starts_with?(METRICS_SHARD_TAG_PREFIX) }
        labels[:shard] = shard.gsub(METRICS_SHARD_TAG_PREFIX, '') if shard
      end

      job_queue_duration_seconds.observe(labels, Time.current - job.queued_at) unless job.queued_at.nil?
      attempt_counter.increment
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def jobs_running_for_project(job)
      return '+Inf' unless runner.instance_type?

      # excluding currently started job
      running_jobs_count = job.project.builds.running.where(runner: Ci::Runner.instance_type)
                              .limit(JOBS_RUNNING_FOR_PROJECT_MAX_BUCKET + 1).count - 1
      running_jobs_count < JOBS_RUNNING_FOR_PROJECT_MAX_BUCKET ? running_jobs_count : "#{JOBS_RUNNING_FOR_PROJECT_MAX_BUCKET}+"
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def failed_attempt_counter
      @failed_attempt_counter ||= Gitlab::Metrics.counter(:job_register_attempts_failed_total, "Counts the times a runner tries to register a job")
    end

    def attempt_counter
      @attempt_counter ||= Gitlab::Metrics.counter(:job_register_attempts_total, "Counts the times a runner tries to register a job")
    end

    def job_queue_duration_seconds
      @job_queue_duration_seconds ||= Gitlab::Metrics.histogram(:job_queue_duration_seconds, 'Request handling execution time', {}, JOB_QUEUE_DURATION_SECONDS_BUCKETS)
    end
  end
end

Ci::RegisterJobService.prepend_if_ee('EE::Ci::RegisterJobService')
