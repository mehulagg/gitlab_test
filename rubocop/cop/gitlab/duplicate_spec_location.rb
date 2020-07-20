# frozen_string_literal: true

require 'rubocop/rspec/top_level_describe'

module RuboCop
  module Cop
    module Gitlab
      # Cop that detects duplicate EE spec files
      #
      # There should not be files in both ee/spec/*/ee/my_spec.rb and ee/spec/*/my_spec.rb
      #
      #  # bad
      #  ee/spec/controllers/my_spec.rb      # describe MyClass
      #  ee/spec/controllers/ee/my_spec.rb   # describe MyClass
      #
      #  # good, spec for EE extension code
      #  ee/spec/controllers/ee/my_spec.rb   # describe MyClass
      #
      #  # good, spec for EE only code
      #  ee/spec/controllers/my_spec.rb      # describe MyClass
      #
      class DuplicateSpecLocation < RuboCop::Cop::Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG = 'Duplicate spec location in `%<path>s`.'
        REGEXP = %r{\A(?<prefix>ee/spec/.*?)(?<ee>/ee)?/(?<suffix>.*)}

        def on_top_level_describe(node, _args)
          path = file_path_for_node(node).delete_prefix("#{rails_root}/")
          duplicate_path = find_duplicate_path(path)

          if duplicate_path && File.exist?(File.join(rails_root, duplicate_path))
            add_offense(node, message: format(MSG, path: duplicate_path))
          end
        end

        private

        def find_duplicate_path(path)
          REGEXP.match(path) do |match|
            if match[:ee]
              File.join(match[:prefix], match[:suffix])
            else
              File.join(match[:prefix], 'ee', match[:suffix])
            end
          end
        end

        def file_path_for_node(node)
          node.location.expression.source_buffer.name
        end

        def rails_root
          File.expand_path('../../..', __dir__)
        end
      end
    end
  end
end
