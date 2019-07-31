# frozen_string_literal: true

module EE
  module Gitlab
    module Scim
      class ParamsParser
        delegate :coerce, to: :class

        FILTER_OPERATORS = %w[eq].freeze
        OPERATIONS_OPERATORS = %w[Replace Add].freeze

        ATTRIBUTE_MAP = {
          id: :extern_uid,
          displayName: :name,
          'name.formatted': :name,
          'emails[type eq "work"].value': :email,
          active: :active,
          externalId: :extern_uid,
          userName: :username
        }.with_indifferent_access.freeze

        COERCED_VALUES = {
          'True' => true,
          'False' => false
        }.freeze

        def initialize(params)
          @params = params.with_indifferent_access
          @hash = {}
        end

        def deprovision_user?
          update_params[:active] == false
        end

        def post_params
          @post_params ||= process_params
        end

        def update_params
          @update_params ||= process_operations
        end

        def filter_params
          @filter_params ||= filter_parser.params
        end

        def filter_operator
          filter_parser.operator.to_sym if filter_parser.valid?
        end

        private

        class FilterParser
          attr_reader :attribute, :operator, :value

          def initialize(filter)
            @attribute, @operator, @value = filter&.split(' ')
          end

          def valid?
            FILTER_OPERATORS.include?(operator) && ATTRIBUTE_MAP[attribute]
          end

          def params
            @params ||= begin
              return {} unless valid?

              { ATTRIBUTE_MAP[attribute] => ParamsParser.coerce(value) }
            end
          end
        end

        def filter_parser
          @filter_parser ||= FilterParser.new(@params[:filter])
        end

        def process_operations
          @params[:Operations].each_with_object({}) do |operation, hash|
            next unless OPERATIONS_OPERATORS.include?(operation[:op])

            attribute = ATTRIBUTE_MAP[operation[:path]]

            hash[attribute] = coerce(operation[:value]) if attribute
          end
        end

        def process_params
          overwrites = { email: parse_emails, name: parse_name }.compact
          parse_params.merge(overwrites)
        end

        def parse_params
          # compact can remove :active if the value for that is nil
          @params.except(:email, :name).compact.each_with_object({}) do |(param, value), hash|
            attribute = ATTRIBUTE_MAP[param]

            hash[attribute] = coerce(value) if attribute
          end
        end

        def parse_emails
          emails = @params[:emails]

          return unless emails

          email = emails.find { |email| email[:type] == 'work' || email[:primary] }
          email[:value] if email
        end

        def parse_name
          name = @params.delete(:name)

          return unless name

          formatted_name = name[:formatted]&.presence
          formatted_name ||= [name[:givenName], name[:familyName]].compact.join(' ')
          @hash[:name] = formatted_name
        end

        def self.coerce(value)
          return value unless value.is_a?(String)

          value = value.delete('\"')
          coerced = COERCED_VALUES[value]

          coerced.nil? ? value : coerced
        end
      end
    end
  end
end
