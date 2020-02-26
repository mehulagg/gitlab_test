# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      class DotenvVariable
        def parse!(blob, build)
          variables = []

          blob.each_line do |line|
            key, value = scan_line!(line)
            variables << build_variable!(build, key, value)
          end

          variables
        end

        private

        def scan_line!(line)
          result = line.scan(/^(.*)=(.*)$/).last

          if result.nil?
            raise Gitlab::Ci::Parsers::ParserError, 'Invalid Format'
          end

          result.each(&:strip!)
        end

        def build_variable!(build, key, value)
          variable = build.dotenv_variables.build(key: key, value: value)

          unless variable.valid?
            raise Gitlab::Ci::Parsers::ParserError, variable.errors.full_messages.to_sentence
          end

          variable
        end
      end
    end
  end
end
