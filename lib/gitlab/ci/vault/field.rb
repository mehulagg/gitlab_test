# frozen_string_literal: true

module Gitlab
  module Ci
    module Vault
      class Field
        include Gitlab::Utils::StrongMemoize

        attr_reader :data

        def initialize(data, key, prefix)
          @name = data[:name].to_sym
          @expose_as = data[:expose_as].presence || "#{key}_#{name}"
          @prefix = prefix
        end

        def expand(data)
          strong_memoize(:data) do
            {
              key: variable_name,
              value: data[name].to_s,
              masked: Maskable::REGEX.match?(data[name].to_s),
              public: false
            }
          end
        end

        private

        attr_reader :name, :expose_as, :prefix

        def variable_name
          [
            prefix.presence,
            expose_as
          ].compact.join("_").parameterize(separator: "_").underscore.upcase
        end
      end
    end
  end
end
