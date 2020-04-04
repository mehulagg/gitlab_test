# frozen_string_literal: true
module Gitlab
  module Ci
    module Parsers
      module Security
        class DastTrace
          def line_number(trace)
            return unless trace.exist?

            line_number = 0
            found = false
            trace.read do |stream|
              stream.limit
              stream.stream.each_line do |line|
                if line =~ /The following .* URLs were scanned*/
                  found = true
                  break
                end

                line_number += 1 unless line =~ /section_end/
              end
            end

            return unless found

            line_number
          end
        end
      end
    end
  end
end
