# frozen_string_literal: true

module Gitlab
  module Ci
    class VaultSecrets
      attr_reader :job

      delegate :project, to: :job

      def initialize(job)
        @job = job
      end

      def call
        return [] unless vault_configured?

        secrets_definitions.map do |var|
          next if restrict_secret_access?(var[:key])

          secret = read_secret(var[:key])
          next unless secret

          build_variables(var, secret.data.compact)
        end.flatten.compact
      end

      def secrets_definitions
        job.options.dig(:secrets, :vault).to_a
      end

      def restrict_secret_access?(key)
        return false if project.protected_for?(job.ref)

        protected_secrets.any? { |regex| regex.match?(key) }
      end

      def protected_secrets
        @protected_secrets ||= vault_service.protected_secrets.map do |secret|
          Gitlab::UntrustedRegexp.new(secret)
        end
      end

      def build_variables(var, data)
        prefix = var[:prefix] || "VAULT"

        if var[:fields].to_a.any?
          build_variables_from_fields(var, data, prefix)
        else
          build_variables_from_data(var, data, prefix)
        end
      end

      def build_variables_from_fields(var, data, prefix)
        var[:fields].map do |field|
          name = variable_name(field, prefix, var[:key])
          build_variable(name, data[field[:name].to_sym])
        end
      end

      def build_variables_from_data(var, data, prefix)
        data.map do |field, value|
          name = variable_name({ name: field }, prefix, var[:key])
          build_variable(name, value)
        end
      end

      def read_secret(path)
        # read secrets from AWS and KV1 secrets engine
        secret = client.logical.read(path)
        return secret if secret

        # Read KV2 secrets engine
        mount, key = path.split('/', 2)
        client.kv(mount).read(key)
      rescue Vault::HTTPError
        # log error
      end

      def build_variable(name, value)
        {
          key: name.to_s,
          value: value.to_s,
          masked: true,
          public: false
        }
      end

      def variable_name(field, prefix, key)
        name = [prefix.presence]

        if field[:expose_as].present?
          name << field[:expose_as]
        else
          name.concat([key, field[:name]])
        end

        name.compact.join('-').parameterize.underscore.upcase
      end

      def client
        vault_service.client
      end

      def vault_configured?
        vault_service && vault_service.enabled?
      end

      def vault_service
        project.vault_integration
      end
    end
  end
end
