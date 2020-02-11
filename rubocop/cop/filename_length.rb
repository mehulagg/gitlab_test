# frozen_string_literal: true

module RuboCop
  module Cop
    class FilenameLength < Cop
      include RangeHelp

      FILENAME_MAX_LENGTH = 100
      MSG_FILENAME_LEN = 'The name of this source file `%<filename>s` ' \
                         'should not exceed 100 characters.'

      def investigate(processed_source)
        file_path = processed_source.file_path
        return if config.file_to_exclude?(file_path)

        for_bad_filename(file_path) do |range, msg|
          add_offense(nil, location: range, message: msg)
        end
      end

      private

      def for_bad_filename(file_path)
        filename = File.basename(file_path)
        return if filename.length < FILENAME_MAX_LENGTH

        yield overflowed_buffer(filename), format(MSG_FILENAME_LEN, filename: filename)
      end

      def override_buffer_with_name(old_buffer, filename)
        Parser::Source::Buffer.new(old_buffer.name, old_buffer.first_line).tap do |new_buffer|
          new_buffer.source = filename
        end
      end

      def overflowed_buffer(filename)
        source_range(override_buffer_with_name(processed_source.buffer, filename), 1, overflow_start_at, filename.length - overflow_start_at)
      end

      def overflow_start_at
        FILENAME_MAX_LENGTH - 1 # Parser::Source::Range are exclusive thus offset
      end
    end
  end
end
