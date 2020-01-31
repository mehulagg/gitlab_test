# frozen_string_literal: true

module Gitlab
  module Ci
    module Vault
      class Secret
        include Gitlab::Utils::StrongMemoize

        NotFoundError = Class.new(StandardError)

        DEFAULT_PREFIX = "VAULT"

        attr_reader :key, :prefix, :client
        attr_accessor :fields

        def initialize(data, client)
          @key = data[:key]
          @prefix = data[:prefix] || DEFAULT_PREFIX
          @client = client
          @raw_fields = data[:fields].to_a
          @fields = []
        end

        def resolve(deadline)
          strong_memoize(:secret) do
            read_secret(deadline)
          end
        end

        def data
          resolve_fields
          fields.map(&:data).compact
        end

        private

        attr_accessor :raw_fields, :secret

        def read_secret(deadline)
          read_logical_secret(deadline) ||
            read_kv_secret(deadline) ||
            raise_secret_error
        end

        def read_logical_secret(deadline)
          deadline.check!

          client.logical.read(key)
        end

        def read_kv_secret(deadline)
          deadline.check!

          mount, path = key.split("/", 2)
          client.kv(mount).read(path)
        end

        def raise_secret_error
          raise NotFoundError, key
        end

        def resolve_fields
          return unless secret
          return if fields.any?

          initialize_fields

          fields.each { |field| field.expand(secret.data) }
        end

        def initialize_fields
          @fields =
            if raw_fields.any?
              fields_from_user
            else
              fields_from_secret
            end
        end

        def fields_from_user
          raw_fields.map { |data| Field.new(data, key, prefix) }
        end

        def fields_from_secret
          secret
            .data
            .keys
            .map { |name| Field.new({ name: name }, key, prefix) }
        end
      end
    end
  end
end
