# frozen_string_literal: true
module Gitlab
  module Ci
    module Parsers
      module Security
        class Report
          def scanned_resources_count(job_artifact)
            scanned_resources_sum = 0
            job_artifact.each_blob do |blob|
              report_data = parse_report_json(blob)
              scanned_resources_sum += report_data.fetch('scan', {}).fetch('scanned_resources', []).length
            end
            scanned_resources_sum
          end

          def line_number(trace)
            return unless trace.raw

            lines_split = trace.raw.split(/The following .* URLs were scanned*/)
            return if lines_split.size < 2

            lines_before_match = lines_split[0]
            lines_before_match.scan(/\n|\r/).size - lines_before_match.scan(/section_end/).size
          end

          private

          def parse_report_json(blob)
            JSON.parse!(blob)
          rescue JSON::ParserError
            {}
          end
        end
      end
    end
  end
end
