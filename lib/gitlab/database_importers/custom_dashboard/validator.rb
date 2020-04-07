# frozen_string_literal: true

# TODO: Do we move this out of :development? Is there a better way to do this?
#       Is there a reason we wouldn't want json-schema in the project?
require 'json-schema'

module Gitlab
  module DatabaseImporters
    module CustomDashboard
      # Validates a raw, unprocessed dashboard.
      class Validator
        InvalidDashboardError = Class.new(StandardError)

        DASHBOARD_SCHEMA_PATH = 'lib/gitlab/metrics/dashboard/schemas/raw/dashboard.json'.freeze

        attr_reader :content

        # @param content [Hash] Representing a raw, unprocessed
        #                   dashboard object
        def initialize(content)
          @content = content
        end

        def execute
          errors = JSON::Validator.fully_validate(schema, content)

          raise InvalidDashboardError.new(errors) unless errors.empty?
        end

        private

        def schema
          JSON.parse(raw_schema)
        end

        def raw_schema
          File.read(Rails.root.join(DASHBOARD_SCHEMA_PATH))
        end
      end
    end
  end
end
