# frozen_string_literal: true

module Gitlab
  module Ci
    #
    # Base GitLab CI Configuration facade
    #
    class Config
      ConfigError = Class.new(StandardError)

      def initialize(config, project: nil, sha: nil, user: nil, with_ports: false)
        excluded_keys = []
        excluded_keys << :ports unless with_ports

        @config = Config::Extendable
          .new(build_config(config, project: project, sha: sha, user: user, excluded_keys: excluded_keys))
          .to_hash

        @global = Entry::Global.new(@config)
        @global.compose!
      rescue Gitlab::Config::Loader::FormatError,
             Extendable::ExtensionError,
             External::Processor::IncludeError => e
        raise Config::ConfigError, e.message
      end

      def valid?
        @global.valid?
      end

      def errors
        @global.errors
      end

      def to_hash
        @config
      end

      ##
      # Temporary method that should be removed after refactoring
      #
      def before_script
        @global.before_script_value
      end

      def image
        @global.image_value
      end

      def services
        @global.services_value
      end

      def after_script
        @global.after_script_value
      end

      def variables
        @global.variables_value
      end

      def stages
        @global.stages_value
      end

      def cache
        @global.cache_value
      end

      def jobs
        @global.jobs_value
      end

      private

      def build_config(config, project:, sha:, user:, excluded_keys: [])
        initial_config = Gitlab::Config::Loader::Yaml.new(config).load!

        exclude_config_keys!(initial_config, excluded_keys)

        if project
          process_external_files(initial_config, project: project, sha: sha, user: user)
        else
          initial_config
        end
      end

      def process_external_files(config, project:, sha:, user:)
        Config::External::Processor.new(config,
          project: project,
          sha: sha || project.repository.root_ref_sha,
          user: user).perform
      end

      def exclude_config_keys!(config, excluded_keys = [])
        return if excluded_keys.empty?

        case config
        when Hash
          config.each do |key, value|
            if excluded_keys.include?(key)
              config.delete(key)
            else
              exclude_config_keys!(value, excluded_keys)
            end
          end
        when Array
          config.map {|e| exclude_config_keys!(e, excluded_keys)}
        end
      end
    end
  end
end
