# frozen_string_literal: true

module Gitlab
  module Diff
    module Formatters
      class MultiTextFormatter < BaseFormatter
        attr_reader :old_start_line
        attr_reader :new_start_line
        attr_reader :old_end_line
        attr_reader :new_end_line

        def initialize(attrs)
          @old_start_line = attrs[:old_start_line]
          @new_start_line = attrs[:new_start_line]
          @old_end_line = attrs[:old_end_line]
          @new_end_line = attrs[:new_end_line]

          super(attrs)
        end

        def all_lines
          [old_start_line, new_start_line, old_end_line, new_end_line]
        end

        def key
          @key ||= super.push(*all_lines)
        end

        def complete?
          old_line.present? || new_line.present?
        end

        def to_h
          super.merge(
            old_start_line: old_start_line,
            new_start_line: new_start_line,
            old_end_line: old_end_line,
            new_end_line: new_end_line
          )
        end

        def start_line_age
          if old_start_line && new_start_line
            nil
          elsif new_start_line
            "new"
          else
            "old"
          end
        end

        def end_line_age
          if old_end_line && new_end_line
            nil
          elsif new_end_line
            "new"
          else
            "old"
          end
        end

        def position_type
          "multi_text"
        end

        def ==(other)
          other.is_a?(self.class) &&
            new_start_line == other.new_start_line &&
            old_start_line == other.old_start_line &&
            new_end_line == other.new_end_line &&
            old_end_line == other.old_end_line
        end
      end
    end
  end
end
