# frozen_string_literal: true

module EE
  module Gitlab
    module Scim
      class ParamsParser
        FILTER_OPERATORS = %w[eq].freeze
        OPERATIONS_OPERATORS = %w[Replace Add].freeze

        ATTRIBUTE_MAP = {
          id: :extern_uid,
          'name.formatted': :name,
          'emails[type eq "work"].value': :email,
          active: :active
        }.with_indifferent_access.freeze

        COERCED_VALUES = {
          'True' => true,
          'False' => false
        }.freeze

        def initialize(params)
          @filter = params[:filter]
          @operations = params[:Operations]
        end

        def deprovision_user?
          data[:active] == false
        end

        def to_hash
          @data ||=
            begin
              hash = {}

              process_filter(hash)
              process_operations(hash)

              hash
            end
        end

        alias_method :data, :to_hash
        private :data

        private

        def process_filter(hash)
          return unless @filter

          attribute, operator, value = @filter.split(' ')

          return unless FILTER_OPERATORS.include?(operator)
          return unless ATTRIBUTE_MAP[attribute]

          hash[ATTRIBUTE_MAP[attribute]] = coerce(value.delete('\"'))
        end

        def process_operations(hash)
          return unless @operations

          @operations.each do |operation|
            next unless OPERATIONS_OPERATORS.include?(operation[:op])

            attribute = ATTRIBUTE_MAP[operation[:path]]

            hash[attribute] = coerce(operation[:value]) if attribute
          end
        end

        def coerce(value)
          coerced = COERCED_VALUES[value]

          coerced.nil? ? value : coerced
        end
      end
    end
  end
end
