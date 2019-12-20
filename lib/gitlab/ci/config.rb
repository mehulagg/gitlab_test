# frozen_string_literal: true

module Gitlab
  module Ci
    #
    # Base GitLab CI Configuration facade
    #
    class Config
      include Gitlab::Utils::StrongMemoize

      ConfigError = Class.new(StandardError)
      TIMEOUT_SECONDS = 30.seconds
      TIMEOUT_MESSAGE = 'Resolving config took longer than expected'

      RESCUE_ERRORS = [
        Gitlab::Config::Loader::FormatError,
        External::Processor::IncludeError
      ].freeze

      attr_reader :root

      def initialize(config, project: nil, sha: nil, user: nil)
        @raw_config = config
        @context    = build_context(project: project, sha: sha, user: user)

        if Feature.enabled?(:ci_limit_yaml_expansion, project, default_enabled: true)
          @context.set_deadline(TIMEOUT_SECONDS)
        end

        @root = Entry::Root.new(expanded_config)
        @root.compose! if valid?
      rescue *rescue_errors => e
        raise Config::ConfigError, e.message
      end

      def valid?
        errors.none? && root.valid?
      end

      def errors
        config_extendable.errors + @root.errors
      end

      def to_hash
        @config
      end

      ##
      # Temporary method that should be removed after refactoring
      #
      def variables
        root.variables_value
      end

      def stages
        root.stages_value
      end

      def jobs
        root.jobs_value
      end

      private

      def expanded_config
        begin
          if Feature.enabled?(:ci_pre_post_pipeline_stages, @context.project, default_enabled: true)
            Config::EdgeStagesInjector.new(extended_config).to_hash
          else
            extended_config
          end
        rescue Gitlab::Config::Loader::Yaml::DataTooLargeError => e
          track_and_raise_for_dev_exception(e)
          raise Config::ConfigError, e.message
        rescue Gitlab::Ci::Config::External::Context::TimeoutError => e
          track_and_raise_for_dev_exception(e)
          raise Config::ConfigError, TIMEOUT_MESSAGE
        end
      end

      def extended_config
        config_extendable.to_hash
      end

      def config_extendable
        strong_memoize(:config_extendable) do
          Config::Extendable.new(processed_with_external_config)
        end
      end

      def processed_with_external_config
        Config::External::Processor.new(loaded_config, @context).perform
      end

      def loaded_config
        Gitlab::Config::Loader::Yaml.new(@raw_config).load!
      end

      def build_context(project:, sha:, user:)
        Config::External::Context.new(
          project: project,
          sha: sha || project&.repository&.root_ref_sha,
          user: user)
      end

      def track_and_raise_for_dev_exception(error)
        Gitlab::ErrorTracking.track_and_raise_for_dev_exception(error, @context.sentry_payload)
      end

      # Overriden in EE
      def rescue_errors
        RESCUE_ERRORS
      end
    end
  end
end

Gitlab::Ci::Config.prepend_if_ee('EE::Gitlab::Ci::ConfigEE')
