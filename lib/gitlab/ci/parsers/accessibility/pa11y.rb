# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Accessibility
        class Pa11y
          Pa11yParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def parse!(json_data, accessibility_report)
            root = JSON.parse(json_data)

            parse_all(root, accessibility_report)
          rescue JSON::ParserError
            raise Pa11yParserError, "JSON parsing failed"
          rescue
            raise Pa11yParserError, "Pa11y parsing failed"
          end

          private

          def parse_all(root, accessibility_report)
            return unless root.present?

            accessibility_report.total = root.dig("total")
            accessibility_report.passes = root.dig("passes")
            accessibility_report.errors = root.dig("errors")

            root.dig("results").each do |url, value|
              accessibility_report.add_url(url, value)
            end

            accessibility_report
          end
        end
      end
    end
  end
end
