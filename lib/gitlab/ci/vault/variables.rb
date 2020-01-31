# frozen_string_literal: true

module Gitlab
  module Ci
    module Vault
      class Variables
        include Gitlab::Utils::StrongMemoize

        def initialize(job, timeout: nil)
          @job = job
          @timeout = (timeout || 10.seconds).to_f
          @secrets = initialize_secrets
        end

        def call
          return [] unless vault_configured?

          SoftTimeout.with_deadline(@timeout) do |deadline|
            secrets.each { |secret| secret.resolve(deadline) }
          end

          secrets.flat_map(&:data)
        end

        def initialize_secrets
          job.options.dig(:secrets, :vault).to_a.each_with_object([]) do |data, secrets|
            secret = Secret.new(data, client)
            secrets << secret if can_read?(secret)
          end
        end

        private

        attr_reader :job
        attr_reader :secrets

        delegate :project, to: :job

        def client
          vault_service.client
        end

        def vault_configured?
          vault_service && vault_service.enabled?
        end

        def vault_service
          project.vault_integration
        end

        def can_read?(secret)
          return true if job.protected?

          protected_secrets.none? { |regex| regex.match?(secret.key) }
        end

        def protected_secrets
          strong_memoize(:protected_secrets) do
            vault_service.protected_secrets.map do |key|
              Gitlab::UntrustedRegexp.new(key)
            end
          end
        end
      end
    end
  end
end
