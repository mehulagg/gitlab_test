# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Variable
        class Dotenv
          def parse!(artifact)
            variables = []

            artifact.each_blob do |blob|
              blob.each_line do |line|
                key, value = line.scan(/^(.*)=(.*)$/).last.each(&:strip!)

                variable = ::Ci::Builds::Dotenv::Variables
                  .new(build_id: artifact.job_id, key: key, value: value)

                unless variable.valid?
                  raise Gitlab::Ci::Parsers::ParserError, variable.errors.full_messages
                end

                variables << variable
              end
            end

            variables
          end
        end
      end
    end
  end
end
