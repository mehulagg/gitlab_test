# frozen_string_literal: true

module Gitlab
  module Ci
    module Vault
      class ProtectedSecret
        include Gitlab::Utils::StrongMemoize

        delegate :match?, to: :path_regexp

        def initialize(config)
          @config = config.split(",", 2)
        end

        def environment_match?(job)
          return true unless has_environment?
          return false unless job.has_environment?

          env_regexp.match?(job.environment)
        end

        private

        def path_regexp
          strong_memoize(:path) do
            Gitlab::UntrustedRegexp.new(@config.first)
          end
        end

        def has_environment?
          @config.last.present?
        end

        def env_regexp
          strong_memoize(:env) do
            Gitlab::UntrustedRegexp.new(@config.last.to_s)
          end
        end
      end
    end
  end
end
